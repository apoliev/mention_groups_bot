class ContextHandler
  include ::Contexts::GroupContext

  attr_reader :mention_bot

  def initialize(mention_bot)
    @mention_bot = mention_bot
  end

  def add_context(context)
    Rails.cache.write(context_key, context, expires_in: 1.hour)
  end

  def delete_context
    Rails.cache.delete(context_key)
  end

  def context
    Rails.cache.read(context_key)
  end

  def handle(txt)
    return if context.blank? || !self.class.method_defined?(context)

    send(context, txt)
  end

  private

  def context_key
    { chat_id: mention_bot.chat.telegram_chat_id, user_id: mention_bot.user.telegram_user_id, type: :context }
  end
end
