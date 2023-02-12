#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Entity.mqh>

namespace Qunity
{
    namespace Chart
    {
        enum ENUM_OHLC_INDEXES
        {
            OHLC_INDEX_OPEN = 0,  // Open
            OHLC_INDEX_HIGH = 1,  // High
            OHLC_INDEX_LOW = 2,   // Low
            OHLC_INDEX_CLOSE = 3, // Close
        };

        enum ENUM_STATES
        {
            STATE_BULLISH = +1, // Bullish
            STATE_MISSING = 0,  // Missing
            STATE_BEARISH = -1, // Bearish
        };

        enum ENUM_AREA_INDEXES
        {
            AREA_INDEX_ENTITY = 0, // Entity
            AREA_INDEX_CHART = 1,  // Chart
        };

        struct MqlOHLCRequest
        {
            datetime Time;
            double Open, High, Low, Close;

            void MqlOHLCRequest(void) : Time(0), Open(0.0), High(0.0), Low(0.0), Close(0.0)
            {
                return;
            };
        };

        class COHLCSeries : public CEntity
        {
        private:
            const int MAX_BAR_SHIFT;

            MqlOHLCRequest Request;

            string Symbols[2];
            ENUM_TIMEFRAMES Timeframes[2];

            bool NewBarFlags[2];
            int BarShifts[2];
            datetime BarTimes[2];

            ENUM_STATES LastState, State;
            datetime LastTimes[4], Times[4];
            double LastPrices[4], Prices[4];

            const int GetBarShift(const ENUM_AREA_INDEXES index, const datetime time) const
            {
                ResetLastError();

                return iBarShift(Symbols[index], Timeframes[index], time);
            };

            const datetime GetBarTime(const ENUM_AREA_INDEXES index, const int shift) const
            {
                ResetLastError();

                return iTime(Symbols[index], Timeframes[index], shift);
            };

        protected:
            void SetState(const ENUM_STATES state)
            {
                State = state;
            };

            void SetTime(const ENUM_OHLC_INDEXES index, const datetime time)
            {
                Times[index] = time;
            };

            void SetPrice(const ENUM_OHLC_INDEXES index, const double price)
            {
                Prices[index] = price;
            };

            const string GetSymbol(const ENUM_AREA_INDEXES index) const
            {
                return Symbols[index];
            };

            const ENUM_TIMEFRAMES GetTimeframe(const ENUM_AREA_INDEXES index) const
            {
                return Timeframes[index];
            };

            const int GetBarShift(const ENUM_AREA_INDEXES index) const
            {
                return BarShifts[index];
            };

            const datetime GetBarTime(const ENUM_AREA_INDEXES index) const
            {
                return BarTimes[index];
            };

            const bool IsNewBarFlag(const ENUM_AREA_INDEXES index) const
            {
                return NewBarFlags[index];
            };

            const MqlOHLCRequest GetRequest(void) const
            {
                return Request;
            };

            const string TimeframeToString(const ENUM_TIMEFRAMES timeframe) const
            {
                string result = EnumToString(timeframe);

                ResetLastError();
                if (StringReplace(result, "PERIOD_", "") < 1)
                {
                    Error("Failed to replace substring 'PERIOD_' to empty string", __FUNCTION__);
                    return NULL;
                };

                return result;
            };

            const bool ForceUpdateOHLC(const MqlOHLCRequest &request)
            {
                Times[OHLC_INDEX_OPEN] = request.Time;
                Prices[OHLC_INDEX_OPEN] = request.Open;

                Times[OHLC_INDEX_HIGH] = request.Time;
                Prices[OHLC_INDEX_HIGH] = request.High;

                Times[OHLC_INDEX_LOW] = request.Time;
                Prices[OHLC_INDEX_LOW] = request.Low;

                Times[OHLC_INDEX_CLOSE] = request.Time;
                Prices[OHLC_INDEX_CLOSE] = request.Close;

                return true;
            };

            const bool RegularUpdateOHLC(const MqlOHLCRequest &request)
            {
                if (Prices[OHLC_INDEX_OPEN] == 0.0)
                    return ForceUpdateOHLC(request);

                if (Prices[OHLC_INDEX_HIGH] <= request.High)
                {
                    Times[OHLC_INDEX_HIGH] = request.Time;
                    Prices[OHLC_INDEX_HIGH] = request.High;
                };

                if (Prices[OHLC_INDEX_LOW] >= request.Low)
                {
                    Times[OHLC_INDEX_LOW] = request.Time;
                    Prices[OHLC_INDEX_LOW] = request.Low;
                };

                Times[OHLC_INDEX_CLOSE] = request.Time;
                Prices[OHLC_INDEX_CLOSE] = request.Close;

                return true;
            };

            virtual const bool SaveLastOHLC(void)
            {
                if (NewBarFlags[AREA_INDEX_ENTITY])
                {
                    LastTimes[OHLC_INDEX_OPEN] = Times[OHLC_INDEX_OPEN];
                    LastPrices[OHLC_INDEX_OPEN] = Prices[OHLC_INDEX_OPEN];

                    LastTimes[OHLC_INDEX_HIGH] = Times[OHLC_INDEX_HIGH];
                    LastPrices[OHLC_INDEX_HIGH] = Prices[OHLC_INDEX_HIGH];

                    LastTimes[OHLC_INDEX_LOW] = Times[OHLC_INDEX_LOW];
                    LastPrices[OHLC_INDEX_LOW] = Prices[OHLC_INDEX_LOW];

                    LastTimes[OHLC_INDEX_CLOSE] = Times[OHLC_INDEX_CLOSE];
                    LastPrices[OHLC_INDEX_CLOSE] = Prices[OHLC_INDEX_CLOSE];
                };

                return true;
            };

            virtual const bool UpdateOHLC(void)
            {
                if (NewBarFlags[AREA_INDEX_ENTITY])
                    return ForceUpdateOHLC(Request);

                return RegularUpdateOHLC(Request);
            };

            virtual const bool SaveLastState(void)
            {
                if (NewBarFlags[AREA_INDEX_ENTITY])
                    LastState = State;

                return true;
            };

            virtual const bool UpdateState(void)
            {
                State = STATE_MISSING;

                if (Prices[OHLC_INDEX_OPEN] < Prices[OHLC_INDEX_CLOSE])
                    State = STATE_BULLISH;
                else if (Prices[OHLC_INDEX_OPEN] > Prices[OHLC_INDEX_CLOSE])
                    State = STATE_BEARISH;

                return true;
            };

            virtual const bool UpdateEntity(void)
            {
                return SaveLastOHLC() && UpdateOHLC() && SaveLastState() && UpdateState();
            };

            const string CreateName(void) const
            {
                const string strTimeframe = TimeframeToString(Timeframes[AREA_INDEX_ENTITY]);

                if (strTimeframe == NULL)
                    return NULL;

                return StringFormat("OHLC(%s,%s)", Symbols[AREA_INDEX_ENTITY], strTimeframe);
            };

            void DeinitEntity(void)
            {
                BarShifts[AREA_INDEX_ENTITY] = BarShifts[AREA_INDEX_CHART] = 0;
                BarTimes[AREA_INDEX_ENTITY] = BarTimes[AREA_INDEX_CHART] = 0;
            };

            void ResetEntity(void)
            {
                State = LastState = STATE_MISSING;

                Times[OHLC_INDEX_OPEN] = Times[OHLC_INDEX_HIGH] =
                    Times[OHLC_INDEX_LOW] = Times[OHLC_INDEX_CLOSE] =
                        LastTimes[OHLC_INDEX_OPEN] = LastTimes[OHLC_INDEX_HIGH] =
                            LastTimes[OHLC_INDEX_LOW] = LastTimes[OHLC_INDEX_CLOSE] = 0;

                Prices[OHLC_INDEX_OPEN] = Prices[OHLC_INDEX_HIGH] =
                    Prices[OHLC_INDEX_LOW] = Prices[OHLC_INDEX_CLOSE] =
                        LastPrices[OHLC_INDEX_OPEN] = LastPrices[OHLC_INDEX_HIGH] =
                            LastPrices[OHLC_INDEX_LOW] = LastPrices[OHLC_INDEX_CLOSE] = 0.0;
            };

        public:
            void COHLCSeries(void) : MAX_BAR_SHIFT(TerminalInfoInteger(TERMINAL_MAXBARS) - 1),
                                     LastState(STATE_MISSING), State(STATE_MISSING)
            {
                Symbols[AREA_INDEX_ENTITY] = Symbols[AREA_INDEX_CHART] = _Symbol;
                Timeframes[AREA_INDEX_ENTITY] = Timeframes[AREA_INDEX_CHART] = _Period;

                BarShifts[AREA_INDEX_ENTITY] = BarShifts[AREA_INDEX_CHART] = 0;
                BarTimes[AREA_INDEX_ENTITY] = BarTimes[AREA_INDEX_CHART] = 0;

                Times[OHLC_INDEX_OPEN] = Times[OHLC_INDEX_HIGH] =
                    Times[OHLC_INDEX_LOW] = Times[OHLC_INDEX_CLOSE] =
                        LastTimes[OHLC_INDEX_OPEN] = LastTimes[OHLC_INDEX_HIGH] =
                            LastTimes[OHLC_INDEX_LOW] = LastTimes[OHLC_INDEX_CLOSE] = 0;

                Prices[OHLC_INDEX_OPEN] = Prices[OHLC_INDEX_HIGH] =
                    Prices[OHLC_INDEX_LOW] = Prices[OHLC_INDEX_CLOSE] =
                        LastPrices[OHLC_INDEX_OPEN] = LastPrices[OHLC_INDEX_HIGH] =
                            LastPrices[OHLC_INDEX_LOW] = LastPrices[OHLC_INDEX_CLOSE] = 0.0;
            };

            const string GetSymbol(void) const
            {
                return Symbols[AREA_INDEX_ENTITY];
            };

            void SetSymbol(const string symbol)
            {
                if (!IsConfigLocked())
                    Symbols[AREA_INDEX_ENTITY] = (symbol != NULL && symbol != "") ? symbol : _Symbol;
            };

            const ENUM_TIMEFRAMES GetTimeframe(void) const
            {
                return Timeframes[AREA_INDEX_ENTITY];
            };

            void SetTimeframe(const ENUM_TIMEFRAMES timeframe)
            {
                if (!IsConfigLocked())
                {
                    const bool isCurTimeframe =
                        (timeframe == NULL || timeframe == PERIOD_CURRENT || timeframe <= _Period);

                    Timeframes[AREA_INDEX_ENTITY] = (isCurTimeframe != true) ? timeframe : _Period;
                };
            };

            const bool Refresh(const datetime time,
                               const double open, const double high, const double low, const double close)
            {
                if (!IsInitialized() || !IsEnabled())
                    return true;

                int shifts[2] = {0, 0};
                datetime times[2] = {0, 0};

                if ((shifts[AREA_INDEX_ENTITY] = GetBarShift(AREA_INDEX_ENTITY, time)) < 0 ||
                    (shifts[AREA_INDEX_CHART] = GetBarShift(AREA_INDEX_CHART, time)) < 0)
                    return Error("Failed to get bar shift index", __FUNCTION__);

                if (MathMax(shifts[AREA_INDEX_ENTITY], shifts[AREA_INDEX_CHART]) > MAX_BAR_SHIFT)
                    return true;

                if ((times[AREA_INDEX_ENTITY] = GetBarTime(AREA_INDEX_ENTITY, shifts[AREA_INDEX_ENTITY])) == 0 ||
                    (times[AREA_INDEX_CHART] = GetBarTime(AREA_INDEX_CHART, shifts[AREA_INDEX_CHART])) == 0)
                    return Error("Failed to get bar opening time", __FUNCTION__);

                NewBarFlags[AREA_INDEX_ENTITY] = (bool)(BarTimes[AREA_INDEX_ENTITY] != times[AREA_INDEX_ENTITY]);
                NewBarFlags[AREA_INDEX_CHART] = (bool)(BarTimes[AREA_INDEX_CHART] != times[AREA_INDEX_CHART]);

                BarShifts[AREA_INDEX_ENTITY] = shifts[AREA_INDEX_ENTITY];
                BarShifts[AREA_INDEX_CHART] = shifts[AREA_INDEX_CHART];

                BarTimes[AREA_INDEX_ENTITY] = times[AREA_INDEX_ENTITY];
                BarTimes[AREA_INDEX_CHART] = times[AREA_INDEX_CHART];

                Request.Time = time;
                Request.Open = open;
                Request.High = high;
                Request.Low = low;
                Request.Close = close;

                if (!UpdateEntity())
                    return Error("Failed to update entity data", __FUNCTION__);

                return true;
            };

            const bool IsNewBar(void) const
            {
                return NewBarFlags[AREA_INDEX_ENTITY];
            };

            const ENUM_STATES GetState(void) const
            {
                return State;
            };

            const ENUM_STATES GetLastState(void) const
            {
                return LastState;
            };

            const datetime GetTime(const ENUM_OHLC_INDEXES index) const
            {
                return Times[index];
            };

            const datetime GetLastTime(const ENUM_OHLC_INDEXES index) const
            {
                return LastTimes[index];
            };

            const double GetPrice(const ENUM_OHLC_INDEXES index) const
            {
                return Prices[index];
            };

            const double GetLastPrice(const ENUM_OHLC_INDEXES index) const
            {
                return LastPrices[index];
            };
        };
    };
};
