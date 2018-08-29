require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, "[ref-notes]コード進行で管理するプレイリスト作成サービス"
    assert_equal full_title("Help"), "Help | [ref-notes]コード進行で管理するプレイリスト作成サービス"
  end
end