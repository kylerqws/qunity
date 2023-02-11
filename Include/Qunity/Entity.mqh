#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Logger.mqh>

namespace Qunity
{
    class CEntity
    {
    private:
        CLogger *Logger;

        string Name;
        bool Enabled, Initialized, ConfigLocked;

    protected:
        const bool IsConfigLocked(void) const
        {
            return ConfigLocked;
        };

        const bool PrintError(const string message) const
        {
            CLogger::PrintError(message);

            return false;
        };

        const bool PrintError(const string message, const string function) const
        {
            CLogger::PrintError(message, function);

            return false;
        };

        const bool Error(const string message) const
        {
            Logger.Error(message);

            return false;
        };

        const bool Error(const string message, const string function) const
        {
            Logger.Error(message, function);

            return false;
        };

        virtual const string CreateName(void) const
        {
            return "";
        };

        virtual const bool InitEntity(void)
        {
            return true;
        };

        virtual void DeinitEntity(void)
        {
            return;
        };

        virtual void ResetEntity(void)
        {
            return;
        };

    public:
        const bool IsInitialized(void) const
        {
            return Initialized;
        };

        const bool IsEnabled(void) const
        {
            return Enabled;
        };

        void SetEnabled(const bool status)
        {
            if (!ConfigLocked)
                Enabled = status;
        };

        const string GetName(void) const
        {
            return Name;
        };

        void SetName(const string name)
        {
            if (!ConfigLocked)
                Name = (name != "") ? name : NULL;
        };

        const CLogger *GetLogger(void) const
        {
            return Logger;
        };

        void SetLogger(CLogger *logger)
        {
            if (!ConfigLocked)
                Logger = logger;
        };

        const bool Init(void)
        {
            if (Initialized)
                Deinit();

            if (!CheckPointer(Logger))
                return PrintError("Invalid logger object pointer in entity dependency", __FUNCTION__);

            if (Enabled && !InitEntity())
                return Error("Failed to initialize entity", __FUNCTION__);

            if (Name == NULL && (Name = CreateName()) == NULL)
                return Error("Failed to create entity identification name", __FUNCTION__);

            Name = (Name != "") ? Name : NULL;
            ConfigLocked = Initialized = true;

            return true;
        };

        void Deinit(void)
        {
            if (!Initialized)
                return;

            Reset();
            if (Enabled)
                DeinitEntity();

            Name = NULL;
            ConfigLocked = Initialized = false;
        };

        void Reset(void)
        {
            if (Initialized && Enabled)
                ResetEntity();
        };
    };
};
