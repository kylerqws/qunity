#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Chart/Trend.mqh>

namespace Qunity
{
    namespace Chart
    {
        enum ENUM_TENDENCY_TYPES
        {
            TENDENCY_TYPE_TREND = 0,   // Trend
            TENDENCY_TYPE_IMPULSE = 1, // Impulse
        };

        enum ENUM_SCREENS
        {
            SCREEN_JUNIOR = 0, // Junior
            SCREEN_MIDDLE = 1, // Middle
            SCREEN_SENIOR = 2, // Senior
        };

        enum ENUM_STATE_INDEXES
        {
            STATE_INDEX_CURRENT = 0, // Current
            STATE_INDEX_BINARY = 1,  // Binary
            STATE_INDEX_TREND = 2,   // Trend
            STATE_INDEX_IMPULSE = 3, // Impulse
        };

        class CTendency : public CTrend
        {
        private:
            const uchar SCREENS_COUNT;

            ENUM_TENDENCY_TYPES Type;
            CTrend *Trends[3];

            bool StateChanges[4];
            ENUM_STATES LastStates[4], States[4];

        protected:
            void SetState(const ENUM_STATE_INDEXES index, const ENUM_STATES state)
            {
                if (index == STATE_INDEX_CURRENT)
                    CTrend::SetState(state);

                States[index] = state;
            };

            const bool Update(void)
            {
                CTrend *junior = Trends[SCREEN_JUNIOR];
                CTrend *middle = Trends[SCREEN_MIDDLE];
                CTrend *senior = Trends[SCREEN_SENIOR];

                const MqlOHLCRequest request = GetRequest();

                if (!junior.Refresh(request.Time, request.Open, request.High, request.Low, request.Close) ||
                    !middle.Refresh(request.Time, request.Open, request.High, request.Low, request.Close) ||
                    !senior.Refresh(request.Time, request.Open, request.High, request.Low, request.Close))
                    return Error("Failed to refresh trend object(s) data", __FUNCTION__);

                return true;
            };

            const bool SaveLastState(void)
            {
                if (IsNewBarFlag(AREA_INDEX_ENTITY))
                {
                    LastStates[STATE_INDEX_CURRENT] = States[STATE_INDEX_CURRENT];
                    LastStates[STATE_INDEX_BINARY] = States[STATE_INDEX_BINARY];
                    LastStates[STATE_INDEX_TREND] = States[STATE_INDEX_TREND];
                    LastStates[STATE_INDEX_IMPULSE] = States[STATE_INDEX_IMPULSE];
                };

                return CTrend::SaveLastState();
            };

            const bool UpdateState(void)
            {
                States[STATE_INDEX_TREND] = STATE_MISSING;

                if (
                    Trends[SCREEN_JUNIOR].GetState() == STATE_BULLISH &&
                    (!Trends[SCREEN_MIDDLE].IsEnabled() || Trends[SCREEN_MIDDLE].GetState() == STATE_BULLISH) &&
                    (!Trends[SCREEN_SENIOR].IsEnabled() || Trends[SCREEN_SENIOR].GetState() == STATE_BULLISH))
                    States[STATE_INDEX_TREND] = STATE_BULLISH;
                else if (
                    Trends[SCREEN_JUNIOR].GetState() == STATE_BEARISH &&
                    (!Trends[SCREEN_MIDDLE].IsEnabled() || Trends[SCREEN_MIDDLE].GetState() == STATE_BEARISH) &&
                    (!Trends[SCREEN_SENIOR].IsEnabled() || Trends[SCREEN_SENIOR].GetState() == STATE_BEARISH))
                    States[STATE_INDEX_TREND] = STATE_BEARISH;

                StateChanges[STATE_INDEX_TREND] =
                    (bool)(States[STATE_INDEX_TREND] != LastStates[STATE_INDEX_TREND]);

                StateChanges[STATE_INDEX_BINARY] =
                    (bool)(States[STATE_INDEX_TREND] != STATE_MISSING &&
                           States[STATE_INDEX_TREND] != LastStates[STATE_INDEX_BINARY]);

                if (IsNewBarFlag(AREA_INDEX_ENTITY))
                    StateChanges[STATE_INDEX_IMPULSE] = false;

                if (StateChanges[STATE_INDEX_BINARY])
                    StateChanges[STATE_INDEX_IMPULSE] =
                        (bool)(States[STATE_INDEX_BINARY] = States[STATE_INDEX_TREND]);

                States[STATE_INDEX_IMPULSE] = States[STATE_INDEX_TREND];
                if (!StateChanges[STATE_INDEX_IMPULSE])
                    States[STATE_INDEX_IMPULSE] = STATE_MISSING;

                if (Type == TENDENCY_TYPE_TREND)
                    SetState(STATE_INDEX_CURRENT, States[STATE_INDEX_TREND]);
                else if (Type == TENDENCY_TYPE_IMPULSE)
                    SetState(STATE_INDEX_CURRENT, States[STATE_INDEX_IMPULSE]);

                StateChanges[STATE_INDEX_CURRENT] =
                    (bool)(States[STATE_INDEX_CURRENT] != LastStates[STATE_INDEX_CURRENT]);

                return true;
            };

            const bool UpdateStrength(void)
            {
                SetStrength(Trends[SCREEN_JUNIOR].GetStrength());

                return true;
            };

            const bool UpdateOHLC(void)
            {
                if (Type == TENDENCY_TYPE_TREND)
                    return CTrend::UpdateOHLC();

                MqlOHLCRequest request = GetRequest();

                if (StateChanges[STATE_INDEX_IMPULSE])
                {
                    datetime openTime = 0;
                    SetPrice(OHLC_INDEX_OPEN, 0.0);

                    for (uchar index = 0; index < SCREENS_COUNT && !IsStopped(); index++)
                    {
                        if (Trends[index].IsEnabled() &&
                            (openTime = Trends[index].GetTime(OHLC_INDEX_OPEN)) < request.Time)
                        {
                            request.Time = openTime;

                            request.Open = Trends[index].GetPrice(OHLC_INDEX_OPEN);
                            request.High = Trends[index].GetPrice(OHLC_INDEX_HIGH);
                            request.Low = Trends[index].GetPrice(OHLC_INDEX_LOW);
                            request.Close = Trends[index].GetPrice(OHLC_INDEX_CLOSE);
                        };
                    };

                    if (States[STATE_INDEX_CURRENT] == STATE_BULLISH)
                        request.Low = GetLastPrice(OHLC_INDEX_LOW);
                    else if (States[STATE_INDEX_CURRENT] == STATE_BEARISH)
                        request.High = GetLastPrice(OHLC_INDEX_HIGH);
                };

                RegularUpdateOHLC(request);

                return true;
            };

            const string CreateName(void) const
            {
                string name = Trends[SCREEN_JUNIOR].GetName();

                if (Trends[SCREEN_MIDDLE].IsEnabled())
                    name = StringFormat("%s ∷ %s", name, Trends[SCREEN_MIDDLE].GetName());

                if (Trends[SCREEN_SENIOR].IsEnabled())
                    name = StringFormat("%s ∷ %s", name, Trends[SCREEN_SENIOR].GetName());

                if (Type == TENDENCY_TYPE_IMPULSE)
                    name = StringFormat("Impulse ∷ %s", name);

                return name;
            };

            const bool InitEntity(void)
            {
                CTrend *junior = Trends[SCREEN_JUNIOR];
                CTrend *middle = Trends[SCREEN_MIDDLE];
                CTrend *senior = Trends[SCREEN_SENIOR];

                if (!CheckPointer(junior) || !CheckPointer(middle) || !CheckPointer(senior))
                    return Error("Invalid trend(s) object pointer in entity dependency", __FUNCTION__);

                if (junior.IsInitialized() || middle.IsInitialized() || senior.IsInitialized())
                    return Error("Trend object(s) mustn't be initialized", __FUNCTION__);

                if (!junior.IsEnabled())
                    return Error("Junior trend object must be always enabled", __FUNCTION__);

                junior.SetSymbol(GetSymbol(AREA_INDEX_ENTITY));
                junior.SetTimeframe(GetTimeframe(AREA_INDEX_ENTITY));
                middle.SetSymbol(GetSymbol(AREA_INDEX_ENTITY));
                senior.SetSymbol(GetSymbol(AREA_INDEX_ENTITY));

                if ((middle.IsEnabled() && junior.GetTimeframe() >= middle.GetTimeframe()) ||
                    (senior.IsEnabled() && junior.GetTimeframe() >= senior.GetTimeframe()) ||
                    (middle.IsEnabled() && senior.IsEnabled() && middle.GetTimeframe() >= senior.GetTimeframe()))
                    return Error("Incorrect tendency timeframe(s) configuration", __FUNCTION__);

                if (!junior.Init() || !middle.Init() || !senior.Init())
                    return Error("Failed to initialize trends object(s)", __FUNCTION__);

                return true;
            };

            void DeinitEntity(void)
            {
                CTrend::DeinitEntity();

                Trends[SCREEN_JUNIOR].Deinit();
                Trends[SCREEN_MIDDLE].Deinit();
                Trends[SCREEN_SENIOR].Deinit();
            };

            void ResetEntity(void)
            {
                CTrend::ResetEntity();

                Trends[SCREEN_JUNIOR].Reset();
                Trends[SCREEN_MIDDLE].Reset();
                Trends[SCREEN_SENIOR].Reset();

                StateChanges[STATE_INDEX_CURRENT] = StateChanges[STATE_INDEX_BINARY] =
                    StateChanges[STATE_INDEX_TREND] = StateChanges[STATE_INDEX_IMPULSE] = false;

                States[STATE_INDEX_CURRENT] = States[STATE_INDEX_BINARY] =
                    States[STATE_INDEX_TREND] = States[STATE_INDEX_IMPULSE] = STATE_MISSING;

                LastStates[STATE_INDEX_CURRENT] = LastStates[STATE_INDEX_BINARY] =
                    LastStates[STATE_INDEX_TREND] = LastStates[STATE_INDEX_IMPULSE] = STATE_MISSING;
            };

        public:
            void CTendency(void) : SCREENS_COUNT(3), Type(TENDENCY_TYPE_TREND)
            {
                States[STATE_INDEX_CURRENT] = States[STATE_INDEX_BINARY] =
                    States[STATE_INDEX_TREND] = States[STATE_INDEX_IMPULSE] = STATE_MISSING;

                LastStates[STATE_INDEX_CURRENT] = LastStates[STATE_INDEX_BINARY] =
                    LastStates[STATE_INDEX_TREND] = LastStates[STATE_INDEX_IMPULSE] = STATE_MISSING;
            };

            const ENUM_TENDENCY_TYPES GetType(void) const
            {
                return Type;
            };

            void SetType(const ENUM_TENDENCY_TYPES type)
            {
                if (!IsConfigLocked())
                    Type = type;
            };

            const CTrend *GetTrend(const ENUM_SCREENS index) const
            {
                return Trends[index];
            };

            void SetTrend(const ENUM_SCREENS index, CTrend *trend)
            {
                if (!IsConfigLocked())
                    Trends[index] = trend;
            };

            const ENUM_STATES GetState(const ENUM_STATE_INDEXES index = STATE_INDEX_CURRENT) const
            {
                return States[index];
            };

            const ENUM_STATES GetLastState(const ENUM_STATE_INDEXES index = STATE_INDEX_CURRENT) const
            {
                return LastStates[index];
            };
        };
    };
};
