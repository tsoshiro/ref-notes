require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:hogeo)
  end
  
  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_path
    
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
  end  
end
