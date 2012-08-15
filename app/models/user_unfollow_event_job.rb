class UserUnfollowEventJob < EventJob
  def initialize(unfollower_id, unfollowee_id)
    action = "User #{link_to_profile unfollower_id} has unfollowed #{link_to_profile unfollowee_id}"
    timestamp = Time.now.to_i
    unfollower = User.find_by_login(unfollower_id)
    # Create the event
    event = unfollower.create_event(action, timestamp)
    # Log the event to the unfollower's stream
    unfollower.log_event(event)
    # Fan out the event to unfollowee
    unfollowee = User.find_by_login(unfollowee_id)
    unfollowee.log_event(event)
    # Fan out the event to all followers
    unfollower.followers.each do |user|
      user.log_event(event)
    end
  end
end
