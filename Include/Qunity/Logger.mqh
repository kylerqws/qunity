#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

namespace Qunity
{
    enum ENUM_LOG_LEVELS
    {
        LOG_LEVEL_NO = 0,    // No
        LOG_LEVEL_INFO = 1,  // Info
        LOG_LEVEL_ERROR = 2, // Error
        LOG_LEVEL_DEBUG = 3, // Debug
    };

    class CLogger
    {
    private:
        ENUM_LOG_LEVELS LogLevel;
        string Identity, LogLevelStrings[4];

    protected:
        static const string GetErrorMessage(const string message, const int error)
        {
            return (error != NULL) ? StringFormat("%s, code %d", message, error) : message;
        };

        const string GetLogString(const ENUM_LOG_LEVELS level, const string message) const
        {
            string logMessage = message;

            if (level == LOG_LEVEL_ERROR)
                logMessage = GetErrorMessage(logMessage, GetLastError());

            return StringFormat("[%s] %s: %s", TimeToString(TimeLocal()), LogLevelStrings[level],
                                (Identity != NULL) ? StringFormat("%s: %s", Identity, logMessage) : logMessage);
        };

    public:
        void CLogger(void) : LogLevel(LOG_LEVEL_NO)
        {
            LogLevelStrings[LOG_LEVEL_NO] = "NO";
            LogLevelStrings[LOG_LEVEL_INFO] = "INFO";
            LogLevelStrings[LOG_LEVEL_ERROR] = "ERROR";
            LogLevelStrings[LOG_LEVEL_DEBUG] = "DEBUG";
        };

        static void PrintError(const string message)
        {
            PrintFormat("[%s] ERROR: %s", TimeToString(TimeLocal()), GetErrorMessage(message, GetLastError()));
        };

        static void PrintError(const string message, const string function)
        {
            PrintError(StringFormat("%s in function %s", message, function));
        };

        const string GetIdentity(void) const
        {
            return Identity;
        };

        void SetIdentity(const string identity)
        {
            Identity = (identity != "") ? identity : NULL;
        };

        const ENUM_LOG_LEVELS GetLogLevel(void) const
        {
            return LogLevel;
        };

        void SetLogLevel(const ENUM_LOG_LEVELS level)
        {
            LogLevel = level;

            if (MQLInfoInteger(MQL_OPTIMIZATION))
                LogLevel = LOG_LEVEL_NO;
            else if (MQLInfoInteger(MQL_DEBUG))
                LogLevel = LOG_LEVEL_DEBUG;
        };

        const bool IsLogging(const ENUM_LOG_LEVELS level) const
        {
            return (bool)(LogLevel != LOG_LEVEL_NO && LogLevel >= level);
        };

        virtual void Log(const ENUM_LOG_LEVELS level, const string message) const
        {
            if (IsLogging(level))
                Print(GetLogString(level, message));
        };

        void Info(const string message) const
        {
            if (IsLogging(LOG_LEVEL_INFO))
                Log(LOG_LEVEL_INFO, message);
        };

        void Error(const string message) const
        {
            if (IsLogging(LOG_LEVEL_ERROR))
                Log(LOG_LEVEL_ERROR, message);
        };

        void Error(const string message, const string function) const
        {
            if (IsLogging(LOG_LEVEL_ERROR))
                Error(StringFormat("%s in function %s", message, function));
        };

        void Debug(const string message) const
        {
            if (IsLogging(LOG_LEVEL_DEBUG))
                Log(LOG_LEVEL_DEBUG, message);
        };

        void Debug(const string message, const string file, const ushort line) const
        {
            if (IsLogging(LOG_LEVEL_DEBUG))
                Debug(StringFormat("%s in file %s on line %d", message, file, line));
        };
    };
};
