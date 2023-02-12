#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Chart/Trend.mqh>

namespace Qunity
{
    namespace Chart
    {
        enum ENUM_ADX_TYPES
        {
            ADX_TYPE_DEFAULT = 0, // ADX Default
            ADX_TYPE_WILDER = 1,  // ADX by Welles Wilder
        };

        class CADXTrend : public CTrend
        {
        private:
            const uint PRELOADED_DATA_SIZE;
            const float STRENGTH_FILTER_FACTOR;

            ENUM_ADX_TYPES ADXType;
            int ADXPeriod;
            uchar ADXFilter;

            datetime TimeBuffer[];
            int ADXHandle, BufferIndex, BufferSize;
            uint PreloadDataSeconds, TimeframeSeconds[2];
            double DeductibleStrength, ADXValue, PDIValue, NDIValue, ADXBuffer[], PDIBuffer[], NDIBuffer[];

            const datetime GetLastTickTime(void) const
            {
                return (datetime)SymbolInfoInteger(GetSymbol(AREA_INDEX_ENTITY), SYMBOL_TIME);
            };

            const bool CopyTimes(const datetime startTime, const datetime endTime)
            {
                ResetLastError();

                BufferSize = CopyTime(GetSymbol(AREA_INDEX_ENTITY), GetTimeframe(AREA_INDEX_ENTITY),
                                      startTime, endTime, TimeBuffer);

                return (bool)(BufferSize >= 0);
            };

            const bool CopyADXBuffers(const datetime startTime, const datetime endTime)
            {
                ResetLastError();

                const int sizes[3] = {
                    CopyBuffer(ADXHandle, MAIN_LINE, startTime, endTime, ADXBuffer),
                    CopyBuffer(ADXHandle, PLUSDI_LINE, startTime, endTime, PDIBuffer),
                    CopyBuffer(ADXHandle, MINUSDI_LINE, startTime, endTime, NDIBuffer),
                };

                BufferSize = MathMin(sizes[ArrayMinimum(sizes)], BufferSize);

                return (bool)(BufferSize >= 0);
            };

        protected:
            const bool Update(void)
            {
                const datetime stime = GetBarTime(AREA_INDEX_ENTITY),
                               etime = (datetime)(stime + PreloadDataSeconds),
                               ttime = GetLastTickTime() - TimeframeSeconds[AREA_INDEX_ENTITY] + 1;

                while (BufferIndex < BufferSize && TimeBuffer[BufferIndex] < stime && !IsStopped())
                    BufferIndex++;

                if (BufferIndex >= BufferSize || TimeBuffer[BufferIndex] > stime || stime >= ttime)
                {
                    BufferIndex = BufferSize = 0;

                    if (!CopyTimes(stime, etime))
                        return Error("Failed to copy bars opening times", __FUNCTION__);

                    if (!CopyADXBuffers(stime, etime))
                        return Error("Failed to copy ADX indicator buffer(s) data", __FUNCTION__);

                    BufferIndex = 0;
                };

                ADXValue = (ADXBuffer[BufferIndex] != EMPTY_VALUE) ? ADXBuffer[BufferIndex] : 0.0;
                PDIValue = (PDIBuffer[BufferIndex] != EMPTY_VALUE) ? PDIBuffer[BufferIndex] : 0.0;
                NDIValue = (NDIBuffer[BufferIndex] != EMPTY_VALUE) ? NDIBuffer[BufferIndex] : 0.0;

                return true;
            };

            const bool UpdateState(void)
            {
                if (ADXValue <= ADXFilter)
                    SetState(STATE_MISSING);
                else
                {
                    if (PDIValue > NDIValue)
                        SetState(STATE_BULLISH);
                    else if (PDIValue < NDIValue)
                        SetState(STATE_BEARISH);
                };

                return true;
            };

            const bool UpdateStrength(void)
            {
                const double strength = ADXValue - DeductibleStrength;

                SetStrength((strength >= 0.0) ? strength : 0.0);

                return true;
            };

            const string CreateName(void) const
            {
                const string strTimeframe = TimeframeToString(GetTimeframe(AREA_INDEX_ENTITY));

                if (strTimeframe == NULL)
                    return NULL;

                return StringFormat("%s(%s,%d,%d)", (ADXType == ADX_TYPE_WILDER) ? "ADXWT" : "ADXT",
                                    strTimeframe, ADXPeriod, ADXFilter);
            };

            const bool InitEntity(void)
            {
                ResetLastError();

                ADXHandle =
                    (ADXType == ADX_TYPE_WILDER)
                        ? iADXWilder(GetSymbol(AREA_INDEX_ENTITY), GetTimeframe(AREA_INDEX_ENTITY), ADXPeriod)
                        : iADX(GetSymbol(AREA_INDEX_ENTITY), GetTimeframe(AREA_INDEX_ENTITY), ADXPeriod);

                if (ADXHandle == INVALID_HANDLE)
                    return Error("Failed to initialize ADX indicator", __FUNCTION__);

                TimeframeSeconds[AREA_INDEX_ENTITY] = PeriodSeconds(GetTimeframe(AREA_INDEX_ENTITY));
                TimeframeSeconds[AREA_INDEX_CHART] = PeriodSeconds(GetTimeframe(AREA_INDEX_CHART));

                PreloadDataSeconds = PeriodSeconds() * PRELOADED_DATA_SIZE;
                DeductibleStrength = ADXFilter * STRENGTH_FILTER_FACTOR;

                return true;
            };

            void DeinitEntity(void)
            {
                if (ADXHandle != INVALID_HANDLE)
                    IndicatorRelease(ADXHandle);

                ADXHandle = INVALID_HANDLE;

                BufferIndex = BufferSize = 0;
                ADXValue = PDIValue = NDIValue = 0.0;
            };

        public:
            void CADXTrend(void) : PRELOADED_DATA_SIZE((1024 * 1024) / (17 * 8)), STRENGTH_FILTER_FACTOR(0.75),
                                   ADXType(ADX_TYPE_DEFAULT), ADXPeriod(14), ADXFilter(0),
                                   ADXHandle(INVALID_HANDLE), ADXValue(0.0), PDIValue(0.0), NDIValue(0.0),
                                   BufferIndex(0), BufferSize(0)
            {
                return;
            };

            const ENUM_ADX_TYPES GetADXType(void) const
            {
                return ADXType;
            };

            void SetADXType(const ENUM_ADX_TYPES type)
            {
                if (!IsConfigLocked())
                    ADXType = type;
            };

            const int GetADXPeriod(void) const
            {
                return ADXPeriod;
            };

            void SetADXPeriod(const int period)
            {
                if (!IsConfigLocked())
                    ADXPeriod = period;
            };

            const uchar GetADXFilter(void) const
            {
                return ADXFilter;
            };

            void SetADXFilter(const uchar filter)
            {
                if (!IsConfigLocked())
                    ADXFilter = filter;
            };
        };
    };
};
