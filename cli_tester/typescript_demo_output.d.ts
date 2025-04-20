// Type definitions for Flutter JS Bridge
// Generated on 2025-04-20T11:05:26.522690

declare global {
  interface Window {
    FlutterJSBridge: FlutterJSBridge;
  }

  interface FlutterJSBridge {
  /**
   * Registers a handler for a specific action from Flutter
   * @param action The action name to register the handler for
   * @param handler The callback function to execute when the action is received
   */
  registerHandler(action: string, handler: (data: any) => any): void;

  /**
   * Unregisters a handler for a specific action
   * @param action The action name to unregister the handler for
   */
  unregisterHandler(action: string): void;

  /**
   * Calls a Flutter method with optional data and waits for a response
   * @param action The action name to call in Flutter
   * @param data Optional data to pass to the Flutter method
   * @returns A Promise that resolves with the response from Flutter
   */
  callFlutter(action: string, data?: any): Promise<any>;

  /**
   * Sends data to Flutter without expecting a response
   * @param action The action name to call in Flutter
   * @param data Optional data to pass to the Flutter method
   */
  sendToFlutter(action: string, data?: any): void;

  /** Fetches user data from Flutter */
  getUserData(userId: string): Promise<UserData>;

  /** Saves user settings to Flutter */
  saveSettings(settings: Settings): Promise<boolean>;

  }

  /** Represents user data */
  interface UserData {
    /** User ID */
    id: string;
    /** User name */
    name: string;
    /** User email */
    email: string;
    /** User age (optional) */
    age?: number;
  }

  /** User settings configuration */
  interface Settings {
    /** UI theme (light/dark) */
    theme: string;
    /** Whether notifications are enabled */
    notifications: boolean;
  }
}

export {};
