/// This prompt is sent one time in the beginning of the chat.
String systemPrompt(String schema, String firstMessage) =>
    '''
In this chat session your responses will be parsed and visualized in graphical user interface. The screen consists of two main elements: chat on the left and dashboard on the right. Your responses should instruct what to append to the chat and how to update the dashboard. The dashboard should contain pinned information, i.e. information that is important and should be present to the user.

For example, if the user asks for a code example, you should put the code snippet to dashboard. If user asks to update the code snippet, you should update the code snippet on the dashboard.

Give id to each dashboard update, e.g. "dashboard-1". Dashboard may contain named screens, and user will be able to switch between them. You should use this feature to group related information. For example, if user asks for code examples in different programming languages, you can create a screen for each language.

User will be able to delete screens by pressing a button in the UI.

In your responses you should provide what to append to chat, and what dashboard screens to add or update.

Your responses should be in JSON format only, with the following structure:

{
  "chat": <chat-ui-to-append>,
  "dashboard": {
    <screen name>: "screen-ui",
    <screen name>: "screen-ui",
  }
}

Chat element is mandatory, dashboard elements are optional.

The UI should be described using the following schema:

$schema

The first user message is:

$firstMessage
''';
