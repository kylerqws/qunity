#property copyright "Copyright 2022 - 2023, kyleRQWS@gmail.com"
#property link "https://vk.com/kylerqws"
#property version "1.00"

#include <Qunity/Entity.mqh>

namespace Qunity
{
    namespace Chart
    {
        enum ENUM_FIBO_RANGES
        {
            FIBO_RANGE_1 = 0, // 000.0 - 100.0
            FIBO_RANGE_2 = 1, // 100.0 - 200.0
            FIBO_RANGE_3 = 2, // 200.0 - 300.0
            FIBO_RANGE_4 = 3, // 300.0 - 400.0
            FIBO_RANGE_5 = 4, // 400.0 - 500.0
            FIBO_RANGE_6 = 5, // 500.0 - 600.0
        };

        enum ENUM_FIBO_TYPES
        {
            FIBO_TYPE_DISABLE = 0,                        // Disabled
            FIBO_TYPE_X000 = 1,                           // …00.0%
            FIBO_TYPE_X236 = 2,                           // …23.6%
            FIBO_TYPE_X000_X236 = 3,                      // …00.0%, …23.6%
            FIBO_TYPE_X382 = 4,                           // …38.2%
            FIBO_TYPE_X000_X382 = 5,                      // …00.0%, …38.2%
            FIBO_TYPE_X236_X382 = 6,                      // …23.6%, …38.2%
            FIBO_TYPE_X000_X236_X382 = 7,                 // …00.0%, …23.6%, …38.2%
            FIBO_TYPE_X500 = 8,                           // …50.0%
            FIBO_TYPE_X000_X500 = 9,                      // …00.0%, …50.0%
            FIBO_TYPE_X236_X500 = 10,                     // …23.6%, …50.0%
            FIBO_TYPE_X000_X236_X500 = 11,                // …00.0%, …23.6%, …50.0%
            FIBO_TYPE_X382_X500 = 12,                     // …38.2%, …50.0%
            FIBO_TYPE_X000_X382_X500 = 13,                // …00.0%, …38.2%, …50.0%
            FIBO_TYPE_X236_X382_X500 = 14,                // …23.6%, …38.2%, …50.0%
            FIBO_TYPE_X000_X236_X382_X500 = 15,           // …00.0%, …23.6%, …38.2%, …50.0%
            FIBO_TYPE_X618 = 16,                          // …61.8%
            FIBO_TYPE_X000_X618 = 17,                     // …00.0%, …61.8%
            FIBO_TYPE_X236_X618 = 18,                     // …23.6%, …61.8%
            FIBO_TYPE_X000_X236_X618 = 19,                // …00.0%, …23.6%, …61.8%
            FIBO_TYPE_X382_X618 = 20,                     // …38.2%, …61.8%
            FIBO_TYPE_X000_X382_X618 = 21,                // …00.0%, …38.2%, …61.8%
            FIBO_TYPE_X236_X382_X618 = 22,                // …23.6%, …38.2%, …61.8%
            FIBO_TYPE_X000_X236_X382_X618 = 23,           // …00.0%, …23.6%, …38.2%, …61.8%
            FIBO_TYPE_X500_X618 = 24,                     // …50.0%, …61.8%
            FIBO_TYPE_X000_X500_X618 = 25,                // …00.0%, …50.0%, …61.8%
            FIBO_TYPE_X236_X500_X618 = 26,                // …23.6%, …50.0%, …61.8%
            FIBO_TYPE_X000_X236_X500_X618 = 27,           // …00.0%, …23.6%, …50.0%, …61.8%
            FIBO_TYPE_X382_X500_X618 = 28,                // …38.2%, …50.0%, …61.8%
            FIBO_TYPE_X000_X382_X500_X618 = 29,           // …00.0%, …38.2%, …50.0%, …61.8%
            FIBO_TYPE_X236_X382_X500_X618 = 30,           // …23.6%, …38.2%, …50.0%, …61.8%
            FIBO_TYPE_X000_X236_X382_X500_X618 = 31,      // …00.0%, …23.6%, …38.2%, …50.0%, …61.8%
            FIBO_TYPE_X764 = 32,                          // …76.4%
            FIBO_TYPE_X000_X764 = 33,                     // …00.0%, …76.4%
            FIBO_TYPE_X236_X764 = 34,                     // …23.6%, …76.4%
            FIBO_TYPE_X000_X236_X764 = 35,                // …00.0%, …23.6%, …76.4%
            FIBO_TYPE_X382_X764 = 36,                     // …38.2%, …76.4%
            FIBO_TYPE_X000_X382_X764 = 37,                // …00.0%, …38.2%, …76.4%
            FIBO_TYPE_X236_X382_X764 = 38,                // …23.6%, …38.2%, …76.4%
            FIBO_TYPE_X000_X236_X382_X764 = 39,           // …00.0%, …23.6%, …38.2%, …76.4%
            FIBO_TYPE_X500_X764 = 40,                     // …50.0%, …76.4%
            FIBO_TYPE_X000_X500_X764 = 41,                // …00.0%, …50.0%, …76.4%
            FIBO_TYPE_X236_X500_X764 = 42,                // …23.6%, …50.0%, …76.4%
            FIBO_TYPE_X000_X236_X500_X764 = 43,           // …00.0%, …23.6%, …50.0%, …76.4%
            FIBO_TYPE_X382_X500_X764 = 44,                // …38.2%, …50.0%, …76.4%
            FIBO_TYPE_X000_X382_X500_X764 = 45,           // …00.0%, …38.2%, …50.0%, …76.4%
            FIBO_TYPE_X236_X382_X500_X764 = 46,           // …23.6%, …38.2%, …50.0%, …76.4%
            FIBO_TYPE_X000_X236_X382_X500_X764 = 47,      // …00.0%, …23.6%, …38.2%, …50.0%, …76.4%
            FIBO_TYPE_X618_X764 = 48,                     // …61.8%, …76.4%
            FIBO_TYPE_X000_X618_X764 = 49,                // …00.0%, …61.8%, …76.4%
            FIBO_TYPE_X236_X618_X764 = 50,                // …23.6%, …61.8%, …76.4%
            FIBO_TYPE_X000_X236_X618_X764 = 51,           // …00.0%, …23.6%, …61.8%, …76.4%
            FIBO_TYPE_X382_X618_X764 = 52,                // …38.2%, …61.8%, …76.4%
            FIBO_TYPE_X000_X382_X618_X764 = 53,           // …00.0%, …38.2%, …61.8%, …76.4%
            FIBO_TYPE_X236_X382_X618_X764 = 54,           // …23.6%, …38.2%, …61.8%, …76.4%
            FIBO_TYPE_X000_X236_X382_X618_X764 = 55,      // …00.0%, …23.6%, …38.2%, …61.8%, …76.4%
            FIBO_TYPE_X500_X618_X764 = 56,                // …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X000_X500_X618_X764 = 57,           // …00.0%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X236_X500_X618_X764 = 58,           // …23.6%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X000_X236_X500_X618_X764 = 59,      // …00.0%, …23.6%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X382_X500_X618_X764 = 60,           // …38.2%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X000_X382_X500_X618_X764 = 61,      // …00.0%, …38.2%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X236_X382_X500_X618_X764 = 62,      // …23.6%, …38.2%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X000_X236_X382_X500_X618_X764 = 63, // …00.0%, …23.6%, …38.2%, …50.0%, …61.8%, …76.4%
            FIBO_TYPE_X786 = 64,                          // …78.6%
            FIBO_TYPE_X000_X786 = 65,                     // …00.0%, …78.6%
            FIBO_TYPE_X236_X786 = 66,                     // …23.6%, …78.6%
            FIBO_TYPE_X000_X236_X786 = 67,                // …00.0%, …23.6%, …78.6%
            FIBO_TYPE_X382_X786 = 68,                     // …38.2%, …78.6%
            FIBO_TYPE_X000_X382_X786 = 69,                // …00.0%, …38.2%, …78.6%
            FIBO_TYPE_X236_X382_X786 = 70,                // …23.6%, …38.2%, …78.6%
            FIBO_TYPE_X000_X236_X382_X786 = 71,           // …00.0%, …23.6%, …38.2%, …78.6%
            FIBO_TYPE_X500_X786 = 72,                     // …50.0%, …78.6%
            FIBO_TYPE_X000_X500_X786 = 73,                // …00.0%, …50.0%, …78.6%
            FIBO_TYPE_X236_X500_X786 = 74,                // …23.6%, …50.0%, …78.6%
            FIBO_TYPE_X000_X236_X500_X786 = 75,           // …00.0%, …23.6%, …50.0%, …78.6%
            FIBO_TYPE_X382_X500_X786 = 76,                // …38.2%, …50.0%, …78.6%
            FIBO_TYPE_X000_X382_X500_X786 = 77,           // …00.0%, …38.2%, …50.0%, …78.6%
            FIBO_TYPE_X236_X382_X500_X786 = 78,           // …23.6%, …38.2%, …50.0%, …78.6%
            FIBO_TYPE_X000_X236_X382_X500_X786 = 79,      // …00.0%, …23.6%, …38.2%, …50.0%, …78.6%
            FIBO_TYPE_X618_X786 = 80,                     // …61.8%, …78.6%
            FIBO_TYPE_X000_X618_X786 = 81,                // …00.0%, …61.8%, …78.6%
            FIBO_TYPE_X236_X618_X786 = 82,                // …23.6%, …61.8%, …78.6%
            FIBO_TYPE_X000_X236_X618_X786 = 83,           // …00.0%, …23.6%, …61.8%, …78.6%
            FIBO_TYPE_X382_X618_X786 = 84,                // …38.2%, …61.8%, …78.6%
            FIBO_TYPE_X000_X382_X618_X786 = 85,           // …00.0%, …38.2%, …61.8%, …78.6%
            FIBO_TYPE_X236_X382_X618_X786 = 86,           // …23.6%, …38.2%, …61.8%, …78.6%
            FIBO_TYPE_X000_X236_X382_X618_X786 = 87,      // …00.0%, …23.6%, …38.2%, …61.8%, …78.6%
            FIBO_TYPE_X500_X618_X786 = 88,                // …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X000_X500_X618_X786 = 89,           // …00.0%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X236_X500_X618_X786 = 90,           // …23.6%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X000_X236_X500_X618_X786 = 91,      // …00.0%, …23.6%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X382_X500_X618_X786 = 92,           // …38.2%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X000_X382_X500_X618_X786 = 93,      // …00.0%, …38.2%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X236_X382_X500_X618_X786 = 94,      // …23.6%, …38.2%, …50.0%, …61.8%, …78.6%
            FIBO_TYPE_X000_X236_X382_X500_X618_X786 = 95, // …00.0%, …23.6%, …38.2%, …50.0%, …61.8%, …78.6%
        };

        enum ENUM_FIBO_LEVELS
        {
            FIBO_LEVEL_000_0 = 0,  // Level 000.0
            FIBO_LEVEL_023_6 = 1,  // Level 023.6
            FIBO_LEVEL_038_2 = 2,  // Level 038.2
            FIBO_LEVEL_050_0 = 3,  // Level 050.0
            FIBO_LEVEL_061_8 = 4,  // Level 061.8
            FIBO_LEVEL_076_4 = 5,  // Level 076.4
            FIBO_LEVEL_078_6 = 6,  // Level 078.6
            FIBO_LEVEL_100_0 = 7,  // Level 100.0
            FIBO_LEVEL_123_6 = 8,  // Level 123.6
            FIBO_LEVEL_138_2 = 9,  // Level 138.2
            FIBO_LEVEL_150_0 = 10, // Level 150.0
            FIBO_LEVEL_161_8 = 11, // Level 161.8
            FIBO_LEVEL_176_4 = 12, // Level 176.4
            FIBO_LEVEL_178_6 = 13, // Level 178.6
            FIBO_LEVEL_200_0 = 14, // Level 200.0
            FIBO_LEVEL_223_6 = 15, // Level 223.6
            FIBO_LEVEL_238_2 = 16, // Level 238.2
            FIBO_LEVEL_250_0 = 17, // Level 250.0
            FIBO_LEVEL_261_8 = 18, // Level 261.8
            FIBO_LEVEL_276_4 = 19, // Level 276.4
            FIBO_LEVEL_278_6 = 20, // Level 278.6
            FIBO_LEVEL_300_0 = 21, // Level 300.0
            FIBO_LEVEL_323_6 = 22, // Level 323.6
            FIBO_LEVEL_338_2 = 23, // Level 338.2
            FIBO_LEVEL_350_0 = 24, // Level 350.0
            FIBO_LEVEL_361_8 = 25, // Level 361.8
            FIBO_LEVEL_376_4 = 26, // Level 376.4
            FIBO_LEVEL_378_6 = 27, // Level 378.6
            FIBO_LEVEL_400_0 = 28, // Level 400.0
            FIBO_LEVEL_423_6 = 29, // Level 423.6
            FIBO_LEVEL_438_2 = 30, // Level 438.2
            FIBO_LEVEL_450_0 = 31, // Level 450.0
            FIBO_LEVEL_461_8 = 32, // Level 461.8
            FIBO_LEVEL_476_4 = 33, // Level 476.4
            FIBO_LEVEL_478_6 = 34, // Level 478.6
            FIBO_LEVEL_500_0 = 35, // Level 500.0
            FIBO_LEVEL_523_6 = 36, // Level 523.6
            FIBO_LEVEL_538_2 = 37, // Level 538.2
            FIBO_LEVEL_550_0 = 38, // Level 550.0
            FIBO_LEVEL_561_8 = 39, // Level 561.8
            FIBO_LEVEL_576_4 = 40, // Level 576.4
            FIBO_LEVEL_578_6 = 41, // Level 578.6
        };

        struct MqlFiboRequest
        {
            double Price1, Price2;

            void MqlFiboRequest(void) : Price1(0.0), Price2(0.0)
            {
                return;
            };
        };

        class CFibonacci : public CEntity
        {
        private:
            const uchar RANGES_COUNT, LEVELS_COUNT;

            MqlFiboRequest Request;
            ENUM_FIBO_TYPES Types[6];

            uchar SizeLevels;
            ENUM_FIBO_LEVELS Levels[];

            string LevelStrings[42];
            double LevelFactors[42];

            double Prices[42];

            const bool ValidateLevel(const ENUM_FIBO_RANGES range, const ENUM_FIBO_LEVELS level) const
            {
                if (Types[range] == FIBO_TYPE_DISABLE)
                    return false;

                string strLevels[], strLevel = EnumToString(level), strType = EnumToString(Types[range]);

                ResetLastError();
                if (StringReplace(strLevel, "FIBO_LEVEL_", "") < 1)
                    return Error("Failed to replace substring 'FIBO_LEVEL_' to empty string", __FUNCTION__);

                ResetLastError();
                if (StringReplace(strLevel, "_", "") < 1)
                    return Error("Failed to replace substring '_' to empty string", __FUNCTION__);

                ResetLastError();
                if (StringReplace(strType, "FIBO_TYPE_", "") < 1)
                    return Error("Failed to replace substring 'FIBO_TYPE_' to empty string", __FUNCTION__);

                ResetLastError();
                if (StringReplace(strType, "X", IntegerToString(range)) < 1)
                    return Error("Failed to replace substring 'X' to range number", __FUNCTION__);

                ResetLastError();
                if (StringSplit(strType, StringGetCharacter("_", 0), strLevels) <= 0)
                    return Error("Failed to split string by '_' character", __FUNCTION__);

                const uchar size = (uchar)ArraySize(strLevels);

                for (uchar index = 0; index < size && !IsStopped(); index++)
                    if (strLevel == strLevels[index])
                        return true;

                return false;
            };

            const bool AddLevel(const ENUM_FIBO_LEVELS level)
            {
                const uchar newSize = SizeLevels + 1;

                ResetLastError();
                if (ArrayResize(Levels, newSize, 42) < newSize)
                    return Error("Failed to resize Fibonacci levels array", __FUNCTION__);

                Levels[newSize - 1] = level;
                SizeLevels = newSize;

                return true;
            };

            void UpdateRequest(const double price1, const double price2)
            {
                Request.Price1 = price1;
                Request.Price2 = price2;
            };

        protected:
            virtual const bool UpdateEntity(void)
            {
                for (uchar index = 0; index < SizeLevels && !IsStopped(); index++)
                {
                    const double factor = LevelToFactor(Levels[index]);

                    if (factor < 0)
                        return Error("Failed to get factor for calculating price of Fibonacci level", __FUNCTION__);

                    Prices[Levels[index]] = Request.Price2 - (Request.Price2 - Request.Price1) * factor;
                };

                return true;
            };

            const string CreateName(void) const
            {
                return StringFormat("Fibo(%d,%d,%d,%d,%d,%d)",
                                    Types[FIBO_RANGE_1], Types[FIBO_RANGE_2], Types[FIBO_RANGE_3],
                                    Types[FIBO_RANGE_4], Types[FIBO_RANGE_5], Types[FIBO_RANGE_6]);
            };

            const bool InitEntity(void)
            {
                for (uchar range = 0; range < RANGES_COUNT && !IsStopped(); range++)
                {
                    if (Types[range] == FIBO_TYPE_DISABLE)
                        continue;

                    for (uchar level = 0; level < LEVELS_COUNT && !IsStopped(); level++)
                    {
                        if (!ValidateLevel((ENUM_FIBO_RANGES)range, (ENUM_FIBO_LEVELS)level))
                            continue;

                        if (!AddLevel((ENUM_FIBO_LEVELS)level))
                            return Error("Failed to add Fibonacci level", __FUNCTION__);
                    };
                };

                return true;
            };

            void DeinitEntity(void)
            {
                CEntity::DeinitEntity();

                SizeLevels = 0;
                ArrayFree(Levels);
            };

            void ResetEntity(void)
            {
                CEntity::ResetEntity();

                ArrayInitialize(Prices, 0.0);
            };

        public:
            void CFibonacci(void) : RANGES_COUNT(6), LEVELS_COUNT(42), SizeLevels(0)
            {
                return;
            };

            const ENUM_FIBO_TYPES GetType(const ENUM_FIBO_RANGES range) const
            {
                return Types[range];
            };

            void SetType(const ENUM_FIBO_RANGES range, const ENUM_FIBO_TYPES type)
            {
                if (!IsConfigLocked())
                    Types[range] = type;
            };

            const string LevelToString(const ENUM_FIBO_LEVELS level)
            {
                string result = LevelStrings[level];

                if (result == NULL)
                {
                    result = EnumToString(level);

                    ResetLastError();
                    if (StringReplace(result, "FIBO_LEVEL_", "") < 1)
                    {
                        Error("Failed to replace substring 'FIBO_LEVEL_' to empty string", __FUNCTION__);

                        return NULL;
                    };

                    ResetLastError();
                    if (StringReplace(result, "_", ".") < 1)
                    {
                        Error("Failed to replace substring '_' to dot character", __FUNCTION__);

                        return NULL;
                    };

                    for (uchar index = 0; index < 2 && !IsStopped(); index++)
                        if (StringGetCharacter(result, 0) == StringGetCharacter("0", 0))
                            result = StringSubstr(result, 1);

                    LevelStrings[level] = result;
                };

                return result;
            };

            const double LevelToFactor(const ENUM_FIBO_LEVELS level)
            {
                double result = LevelFactors[level];

                if (result == 0.0 && level != 0)
                {
                    const string strLevel = LevelToString(level);

                    if (strLevel == NULL)
                    {
                        Error("Failed to get text format of Fibonacci level", __FUNCTION__);

                        return -1;
                    };

                    LevelFactors[level] = (result = StringToDouble(strLevel) / 100);
                };

                return result;
            };

            const uchar GetSizeLevels(void) const
            {
                return SizeLevels;
            };

            const bool CopyLevels(ENUM_FIBO_LEVELS &levels[]) const
            {
                ArrayFree(levels);

                ResetLastError();
                if (ArrayCopy(levels, Levels) < SizeLevels)
                    return Error("Failed to copy Fibonacci levels to inputted array", __FUNCTION__);

                return true;
            };

            const bool Refresh(const double price1, const double price2)
            {
                if (!IsEnabled() || !IsInitialized())
                    return true;

                UpdateRequest(price1, price2);

                if (!UpdateEntity())
                    return Error("Failed to update entity data", __FUNCTION__);

                return true;
            };

            const double GetPrice(const ENUM_FIBO_LEVELS level) const
            {
                return Prices[level];
            };
        };
    };
};
