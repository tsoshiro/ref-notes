require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new( name:"Hogehoge Fugao",
                      email:"fugao@hogeo.com",
                      password:"password",
                      password_confirmation:"password")
  end
  
  test "should be valid" do 
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = 'a' * 151
    assert_not @user.valid?
  end
  
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
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. 
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