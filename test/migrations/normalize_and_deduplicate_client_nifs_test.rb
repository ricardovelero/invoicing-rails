# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/migrate/20260920203554_normalize_and_deduplicate_client_nifs')

class NormalizeAndDeduplicateClientNifsTest < ActiveSupport::TestCase
  test 'generated duplicate markers do not collide across normalized nif groups' do
    user = users(:first)

    clients = [
      create_raw_client(user:, nif: 'ABCDEFGHI111'),
      create_raw_client(user:, nif: 'ABCDEFGHI111'),
      create_raw_client(user:, nif: 'ABCDEFGHI222'),
      create_raw_client(user:, nif: 'ABCDEFGHI222')
    ]

    NormalizeAndDeduplicateClientNifs.new.migrate(:up)

    nifs = clients.map { |client| client.reload.nif }

    assert_equal 4, nifs.uniq.size
    assert_includes nifs, 'ABCDEFGHI111'
    assert_includes nifs, 'ABCDEFGHI222'
    assert_includes nifs, 'ABCDEFGHI-D1'
    assert_includes nifs, 'ABCDEFGHI-D2'
  end

  test 'generated marker skips an already occupied nif' do
    user = users(:first)

    create_raw_client(user:, nif: 'ABCDEFGHI111')
    duplicate = create_raw_client(user:, nif: 'ABCDEFGHI111')
    create_raw_client(user:, nif: 'ABCDEFGHI-D1')

    NormalizeAndDeduplicateClientNifs.new.migrate(:up)

    assert_equal 'ABCDEFGHI-D2', duplicate.reload.nif
  end

  private

  def create_raw_client(user:, nif:)
    NormalizeAndDeduplicateClientNifs::MigrationClient.create!(
      user_id: user.id,
      nif:
    )
  end
end
