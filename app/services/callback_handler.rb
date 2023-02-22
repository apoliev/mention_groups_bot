class CallbackHandler
  include ::Callbacks::GroupCallback

  attr_reader :mention_bot

  def initialize(mention_bot)
    @mention_bot = mention_bot
  end

  def add_target(target)
    Rails.cache.write(callback_key, target)
  end

  def delete_target
    Rails.cache.delete(callback_key)
  end

  def target
    Rails.cache.read(callback_key)
  end

  def handle(data)
    callback_type, command = data.split(':')
    method_name = "#{callback_type}_handler"
    return unless self.class.method_defined?(method_name)

    send(method_name, command)
  end

  private

  def callback_key
    { chat_id: mention_bot.chat.telegram_chat_id, user_id: mention_bot.user.telegram_user_id, type: :callback }
  end
end
