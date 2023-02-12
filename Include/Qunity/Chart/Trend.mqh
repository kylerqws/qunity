#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Chart/OHLCSeries.mqh>

namespace Qunity
{
    namespace Chart
    {
        class CTrend : public COHLCSeries
        {
        private:
            double LastStrength, Strength;

        protected:
            void SetStrength(const double strength)
            {
                Strength = strength;
            };

            virtual const bool Update(void)
            {
                return false;
            };

            const bool UpdateState(void)
            {
                return false;
            };

            virtual const bool SaveLastStrength(void)
            {
                if (IsNewBarFlag(AREA_INDEX_ENTITY))
                    LastStrength = Strength;

                return true;
            };

            virtual const bool UpdateStrength(void)
            {
                return false;
            };

            const bool UpdateOHLC(void)
            {
                const ENUM_STATES curState = GetState();

                if (curState != STATE_MISSING && curState != GetLastState())
                    return ForceUpdateOHLC(GetRequest());

                return RegularUpdateOHLC(GetRequest());
            };

            const bool UpdateEntity(void)
            {
                return Update() && SaveLastState() && UpdateState() &&
                       SaveLastStrength() && UpdateStrength() && SaveLastOHLC() && UpdateOHLC();
            };

            const string CreateName(void) const
            {
                return NULL;
            };

            void ResetEntity(void)
            {
                COHLCSeries::ResetEntity();

                Strength = LastStrength = 0.0;
            };

        public:
            void CTrend(void) : LastStrength(0.0), Strength(0.0)
            {
                return;
            };

            const double GetStrength(void) const
            {
                return Strength;
            };

            const double GetLastStrength(void) const
            {
                return LastStrength;
            };
        };
    };
};
