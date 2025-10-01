# ffui

Flutter Framework UI for Gemini CLI.

## Start

In VS Code, open [this fork of gemini-cli](https://github.com/polina-c/gemini-cli/tree/for-ff) and:

1.  Compile code:

    ```
    npm install
    npm run build
    ```

2.  Start A2A server of GeminiCLI,

    ```
    npm run start:a2a-server
    ```

3.  Start flutter app:

    ```
    cd packages/ffui
    flutter run -d macos
    ```

4.  Chat with the agent assuming it has access only to the repo files,
    and only in sandbox. For example,
    ask to tweak `packages/a2a-server/src/types.ts`.
