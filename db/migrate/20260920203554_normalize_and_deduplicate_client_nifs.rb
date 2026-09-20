# frozen_string_literal: true

# Client#normalize_nif strips/upcases nif on every save going forward, but a
# pre-existing row only gets normalized the next time something happens to
# save it -- deploying the callback doesn't touch data already at rest. Until
# then, two clients for the same user whose nif only differed by case or
# padding (e.g. "b1234567x" and "B1234567X ") could both exist, because the
# uniqueness check only ever compared an already-normalized value against
# whatever raw, unnormalized value the other row still had. The moment both
# happen to be normalized, they become identical, and any later save of
# either row -- even one that never touches nif -- fails validation out of
# nowhere.
#
# This backfills every nif through that same strip/upcase, and for any
# (user_id, normalized nif) pair that collides once cleaned, keeps the oldest
# row's value canonical and appends a short, length-safe "-Dn" marker to the
# newer ones so they stay saveable. A migration should not silently invent a
# new value for what is, for these rows, someone's real tax id, so the
# suffixed rows are logged here for manual review rather than merged or
# renamed to anything meaningful.
#
# A migration-local class, not the app's Client, for the same reason as
# RepairSequenceCountersBehindTheirSeries: this has to keep working even
# after Client's validations or columns change. NIF_MAX_LENGTH mirrors
# Client's `validates :nif, length: { maximum: 12 }` as of this writing.
class NormalizeAndDeduplicateClientNifs < ActiveRecord::Migration[8.1]
  NIF_MAX_LENGTH = 12

  # :nodoc:
  class MigrationClient < ActiveRecord::Base
    self.table_name = 'clients'
  end

  def up
    groups = MigrationClient.unscoped.group_by { |client| [client.user_id, normalize(client.nif)] }
    groups.each do |(_user_id, normalized), clients|
      next if normalized.blank?

      clients.sort_by(&:id).each_with_index { |client, index| resolve(client, normalized, index) }
    end
  end

  def down; end

  private

  def resolve(client, normalized, index)
    target = index.zero? ? normalized : dedupe(normalized, index)
    return if client.nif == target

    say "client #{client.id}: #{client.nif.inspect} -> #{target.inspect}#{' (needs manual review)' if index.positive?}"
    client.update_column(:nif, target)
  end

  def dedupe(normalized, index)
    suffix = "-D#{index}"
    "#{normalized[0, NIF_MAX_LENGTH - suffix.length]}#{suffix}"
  end

  def normalize(nif)
    nif&.strip&.upcase
  end
end
