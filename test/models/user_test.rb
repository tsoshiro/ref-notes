require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new( user_name: "hogeo",
                      display_name: "Hogehoge Fugao",
                      email:"fugao@hogeo.com",
                      slug: "hogeo",
                      password:"password",
                      password_confirmation:"password")
  end
  
  test "should be valid" do 
    assert @user.valid?
  end
  
  # user_name test
  test "user_name should be present" do
    @user.user_name = " "
    assert_not @user.valid?
  end
  
  test "user_name should not be too long" do
    @user.user_name = 'a' * 26
    assert_not @user.valid?
  end
  
  test "user_name should be written in right format" do
    valid_user_name = %w[hogeo HOGEO hOgEo hoge-hogeo hoge_hogo]
    valid_user_name.each do |user_name|
      @user.user_name = user_name
      assert @user.valid?, "#{user_name} should be valid"
    end
  end
  
  test "user_name should not be written in wrong format" do
    invalid_user_name = %w["hoge hogeo" hoge.hogeo ほげお]
    invalid_user_name.each do |user_name|
      @user.user_name = user_name
      assert_not @user.valid?, "#{user_name.inspect} should be invalid"
    end
  end
  
  test "user_name should be saved as lower case" do
    mixed_case_user_name = "hogeHogeO"
    @user.user_name = mixed_case_user_name
    @user.save
    assert_equal mixed_case_user_name.downcase, @user.reload.email
  end

  # display_name test
  test "display_name should be present" do
    @user.display_name = " "
    assert_not @user.valid?
  end
  
  test "display_name should not be too long" do
    @user.display_name = 'a' * 151
    assert_not @user.valid?
  end
  
  # Email test
  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end
  
  test "email should be not too long" do
    @user.email = 'a' * (256 - "@example.com".length)
    assert_not @user.valid?
  end
  
  test "email should be written in a right format" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "#{address} should be valid"
    end
  end
  
  test "email should not be written in a wrong format" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.user_name@example. 
                        foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    
    invalid_addresses.each do |address|
      @user.email = address
      assert_not @user.valid?, "#{address.inspect} should be invalid"
    end
  end
  
  test "email should be saved as lower-case" do
    mixed_case_email = "Foo@ExAmPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end
  
  # Password test
  test "password should be not be empty" do
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
  end
  
  test "password should be over 8 characters" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    # remember_digestの属性をもたないsetupで生成されたユーザーでauthenticated?メソッドを実行
    # remember_digestがnilなので、エラーが返る
    assert_not @user.authenticated?('')
  end
end