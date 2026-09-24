# frozen_string_literal: true

# Generated markers are allocated against every normalized nif already
# occupied by that user, not just against duplicates from the same group.
# This prevents two different long nifs with the same truncated prefix from
# receiving the same "-Dn" marker, and also avoids colliding with an existing
# nif that already looks like a generated marker.

# Reserve every real normalized nif before allocating synthetic markers so a
# generated value can never collide with another group or an existing nif.
# occupied = Hash.new { |hash, user_id| hash[user_id] = Set.new }

# groups.each_key do |user_id, normalized|
#  occupied[user_id] << normalized if normalized.present?
# end

class NormalizeAndDeduplicateClientNifs < ActiveRecord::Migration[8.1]
  NIF_MAX_LENGTH = 12

  # :nodoc:
  class MigrationClient < ActiveRecord::Base
    self.table_name = 'clients'
  end

  def up
    groups = MigrationClient.unscoped.group_by do |client|
      [client.user_id, normalize(client.nif)]
    end

    occupied = Hash.new { |hash, user_id| hash[user_id] = Set.new }

    groups.each_key do |user_id, normalized|
      occupied[user_id] << normalized if normalized.present?
    end

    groups.each do |(user_id, normalized), clients|
      next if normalized.blank?

      clients.sort_by(&:id).each_with_index do |client, index|
        target =
          if index.zero?
            normalized
          else
            dedupe(normalized, occupied[user_id])
          end

        resolve(client, target, index)
        occupied[user_id] << target
      end
    end
  end

  def down; end

  private

  def resolve(client, target, index)
    return if client.nif == target

    say "client #{client.id}: #{client.nif.inspect} -> #{target.inspect}#{' (needs manual review)' if index.positive?}"
    client.update_column(:nif, target)
  end

  def dedupe(normalized, occupied)
    index = 1

    loop do
      suffix = "-D#{index}"
      prefix_length = NIF_MAX_LENGTH - suffix.length

      if prefix_length <= 0
        raise ActiveRecord::MigrationError,
              "Unable to generate unique NIF marker for #{normalized.inspect}"
      end

      candidate = "#{normalized[0, prefix_length]}#{suffix}"
      return candidate unless occupied.include?(candidate)

      index += 1
    end
  end

  def normalize(nif)
    nif&.strip&.upcase
  end
end
