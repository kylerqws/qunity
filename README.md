# Qunity Trading System

* **OHLC** - индикатор отображает OHLC серии старших таймфреймов;
* **ADXT** - трендовый индикатор на основе индикатора ADX / ADXWilder;
* **ADXMT** - мультитаймфреймовый трендовый индикатор, на основе индикатора ADX / ADXWilder;
* **ADXMT-F** - мультитаймфреймовый трендовый индикатор, на основе индикатора ADX / ADXWilder c уровнями Фибоначчи.

## ADX Trend indicator (ADXT)

Индикатор показывает трендовые участки, используя данные индикатора ADX или ADXWilder.

### Принцип работы индикатора:
- если PDI больше NDI, то устанавливается бычье движение;
- если PDI меньше NDI, то устанавливается медвежье движение;
- если ADX меньше либо равен значению фильтра, указанного в параметрах, то состояние движения отсутствует.

### Входные параметры индикатора:
- Calculate Timeframe - таймфрейм для расчета;
- ADX Type - тип расчета ADX, на основании которого происходит расчет;
- ADX Period - период используемого расчета;
- ADX Filter - фильтр значения ADX;
- Logging - тип логирования в журнале.

Благодаря параметру Calculate Timeframe вы можете отображать значения старших таймфреймов на младшем графике.
Стоит учесть, что для подсчета старших таймфреймов используется последний закрывшийся бар старшего таймфрейма.

### Значения в окне "Обзор рынка":
- Direction - направление тренда;
- Strength - сила тренда;
- Open - цена начала тренда;
- High - максимальная цена в течении тренда;
- Low - минимальная цена в течении тренда;
- Close - цена завершения тренда.

Направление тренда может быть от -1 до +1, где +1 - бычий тренд, 0 - отсутствует какой-либо тренд, -1 - медвежий тренд.
Сила тренда высчитывается по формуле: значение ADX - (значение параметра ADX Filter * 0.75).
Смена тренда на значение "0" не останавливает подсчет цен предыдущего тренда, а так же значения "Open" и "Close" могут не совпадать с открытием бара на графике, т.к. тренд может смениться в процессе формирования бара.

## ADX Multi-Timeframe Trend indicator (ADXMT)

Индикатор показывает трендовые участки, используя данные индикатора ADX или ADXWilder с нескольких таймфреймов.
Импульсный режим индикатора позволяет поймать начало тренда, а несколько "Экранов" с разными таймфреймами позволяют отфильтровать рыночный шум.

### Принцип работы индикатора:
- если PDI больше NDI, то устанавливается бычье движение;
- если PDI меньше NDI, то устанавливается медвежье движение;
- для определения какого-либо тренда необходимо выполнение вышеуказанных пунктов на всех включенных "Экранах";
- если ADX меньше либо равен значению фильтра, указанного в параметрах, то состояние движения отсутствует;
- если включен "Импульсный" режим, то данные о тренде считаются от начала формирования тренда на любом из "Экранов" до смены тренда на противоположный на всех "Экранах".

### Входные параметры индикатора:
- Calculate Timeframe - таймфрейм текущего, т.е. "Junior" экрана для расчета;
- Tendency Type - тип расчета индикатора;
- Config Screen Junior - тип расчета ADX на "Junior" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Junior" экрана;
- ADX Filter - фильтр значения ADX на "Junior" экране;
- Config Screen Middle - включить/выключить "Middle" экран для расчета;
- ADX Type - тип расчета ADX на "Middle" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Middle" экрана;
- ADX Filter - фильтр значения ADX на "Middle" экране;
- Config Screen Senior - включить/выключить "Senior" экран для расчета;
- ADX Type - тип расчета ADX на "Senior" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Senior" экрана;
- ADX Filter - фильтр значения ADX на "Senior" экране;
- Logging - тип логирования в журнале.

Благодаря параметру Calculate Timeframe вы можете отображать значения старших таймфреймов на младшем графике для "Junior" экрана.
Стоит учесть, что для подсчета старших таймфреймов используется последний закрывшийся бар старшего таймфрейма.

### Значения в окне "Обзор рынка":
- Direction - направление тренда;
- Strength - сила тренда;
- Open - цена начала тренда;
- High - максимальная цена в течении тренда;
- Low - минимальная цена в течении тренда;
- Close - цена завершения тренда.

Направление тренда может быть от -1 до +1, где +1 - бычий тренд, 0 - отсутствует какой-либо тренд, -1 - медвежий тренд.
Сила тренда высчитывается по формуле: значение ADX - (значение параметра ADX Filter * 0.75).
Смена тренда на значение "0" не останавливает подсчет цен предыдущего тренда, а так же значения "Open" и "Close" могут не совпадать с открытием бара на графике, т.к. тренд может смениться в процессе формирования бара.
В импульсном режиме начало тренда считается сменой тренда на противоположный на всех "Экранах".

## ADX Multi-Timeframe Trend indicator with Fibonacci levels (ADXMT-F)

Индикатор показывает трендовые участки, используя данные индикатора ADX или ADXWilder с нескольких таймфреймов.
Импульсный режим индикатора позволяет поймать начало тренда, а несколько "Экранов" с разными таймфреймами позволяют отфильтровать рыночный шум.
На график цены добавляются уровни Фибоначчи, которые имеют гибкие настройки.

### Принцип работы индикатора:
- если PDI больше NDI, то устанавливается бычье движение;
- если PDI меньше NDI, то устанавливается медвежье движение;
- для определения какого-либо тренда необходимо выполнение вышеуказанных пунктов на всех включенных "Экранах";
- если ADX меньше либо равен значению фильтра, указанного в параметрах, то состояние движения отсутствует;
- если включен "Импульсный" режим, то данные о тренде считаются от начала формирования тренда на любом из "Экранов" до смены тренда на противоположный на всех "Экранах";
- уровни Фибоначчи, если они включены, рисуются на основе максимальной (при восходящей тенденции) и минимальной (при нисходящей тенденции) и максимальной/минимальной ценами за предшествующую тенденцию.

### Входные параметры индикатора:
- Calculate Timeframe - таймфрейм текущего, т.е. "Junior" экрана для расчета;
- Tendency Type - тип расчета индикатора;
- Config Screen Junior - тип расчета ADX на "Junior" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Junior" экрана;
- ADX Filter - фильтр значения ADX на "Junior" экране;
- Config Screen Middle - включить/выключить "Middle" экран для расчета;
- ADX Type - тип расчета ADX на "Middle" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Middle" экрана;
- ADX Filter - фильтр значения ADX на "Middle" экране;
- Config Screen Senior - включить/выключить "Senior" экран для расчета;
- ADX Type - тип расчета ADX на "Senior" экране, на основании которого происходит расчет;
- ADX Period - период используемого расчета "Senior" экрана;
- ADX Filter - фильтр значения ADX на "Senior" экране;
- Show Fibonacci Levels - включить/выключить отображение уровней Фибоначчи на графике;
- Range #1 - список уровней, которые будут отображаться для диапазона от 0.0% до 99.9%;
- Range #2 - список уровней, которые будут отображаться для диапазона от 100.0% до 199.9%;
- Range #3 - список уровней, которые будут отображаться для диапазона от 200.0% до 299.9%;
- Range #4 - список уровней, которые будут отображаться для диапазона от 300.0% до 399.9%;
- Range #5 - список уровней, которые будут отображаться для диапазона от 400.0% до 499.9%;
- Range #6 - список уровней, которые будут отображаться для диапазона от 500.0% до 599.9%;
- Round Levels - показывать ли текст описания для "круглых" уровней;
- Color - цвет уровня;
- Style - стиль уровня;
- Width - ширина линии уровня;
- Half Levels - показывать ли текст описания для "дробных-половинных" уровней;
- Color - цвет уровня;
- Style - стиль уровня;
- Width - ширина линии уровня;
- Float Levels - показывать ли текст описания для "дробных" уровней;
- Color - цвет уровня;
- Style - стиль уровня;
- Width - ширина линии уровня;
- Logging - тип логирования в журнале.

Благодаря параметру Calculate Timeframe вы можете отображать значения старших таймфреймов на младшем графике для "Junior" экрана.
Стоит учесть, что для подсчета старших таймфреймов используется последний закрывшийся бар старшего таймфрейма.

### Значения в окне "Обзор рынка":
- Direction - направление тренда;
- Strength - сила тренда;
- Open - цена начала тренда;
- High - максимальная цена в течении тренда;
- Low - минимальная цена в течении тренда;
- Close - цена завершения тренда.

Направление тренда может быть от -1 до +1, где +1 - бычий тренд, 0 - отсутствует какой-либо тренд, -1 - медвежий тренд.
Сила тренда высчитывается по формуле: значение ADX - (значение параметра ADX Filter * 0.75).
Смена тренда на значение "0" не останавливает подсчет цен предыдущего тренда, а так же значения "Open" и "Close" могут не совпадать с открытием бара на графике, т.к. тренд может смениться в процессе формирования бара.
В импульсном режиме начало тренда считается сменой тренда на противоположный на всех "Экранах".
