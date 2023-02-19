<chart>
period_type=1
period_size=4
scale=8
mode=0
fore=1
grid=0
volume=0
scroll=1
shift=1
shift_size=25.000000
ticker=1
ohlc=0
one_click=0
one_click_btn=0
bidline=1
askline=1
lastline=0
days=1
descriptions=1
tradelines=1
tradehistory=1
window_type=3
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=32768
grid_color=12632256
bidline_color=12632256
askline_color=12632256
lastline_color=12632256
stops_color=17919
<window>
<indicator>
name=Main
</indicator>
<indicator>
name=Ichimoku Kinko Hyo
tenkan=32
kijun=88
senkou=176
<graph>
draw=128
style=0
width=3
color=7059389
</graph>
<graph>
draw=128
style=0
width=3
color=8034025
</graph>
<graph>
draw=128
style=2
width=1
shift=88
color=6333684
</graph>
<graph>
draw=128
style=2
width=1
shift=88
color=14204888
</graph>
<graph>
draw=128
style=0
width=2
color=2139610
</graph>
</indicator>
</window>
<window>
height=20.000000
<indicator>
name=Custom Indicator
path=Indicators\Qunity\ADXMT-F.ex5
scale_fix_min=1
scale_fix_min_val=0.000000
<graph>
name=ADXMT-F ∷ Direction
draw=0
style=0
width=1
color=-1
</graph>
<graph>
name=ADXMT-F ∷ Strength
draw=11
style=0
width=5
color=255,42495,32768,8034025,2139610,7059389
</graph>
<graph>
name=ADXMT-F ∷ Open
draw=0
style=0
width=1
color=-1
</graph>
<graph>
name=ADXMT-F ∷ High
draw=0
style=0
width=1
color=-1
</graph>
<graph>
name=ADXMT-F ∷ Low
draw=0
style=0
width=1
color=-1
</graph>
<graph>
name=ADXMT-F ∷ Close
draw=0
style=0
width=1
color=-1
</graph>
<inputs>
CalcTimeframe=0
TendencyType=1
ADX0Type=1
ADX0Period=8
ADX0Filter=20
ADX1Enabled=true
ADX1Timeframe=16408
ADX1Type=1
ADX1Period=5
ADX1Filter=20
ADX2Enabled=false
ADX2Timeframe=16408
ADX2Type=1
ADX2Period=5
ADX2Filter=20
ShowFiboLevels=true
FiboRange1Type=95
FiboRange2Type=95
FiboRange3Type=95
FiboRange4Type=95
FiboRange5Type=95
FiboRange6Type=95
RoundLevelsText=true
RoundLevelColor=8421504
RoundLevelStyle=0
RoundLevelWidth=2
HalfLevelsText=true
HalfLevelColor=11119017
HalfLevelStyle=0
HalfLevelWidth=1
FloatLevelsText=false
FloatLevelColor=13882323
FloatLevelStyle=2
FloatLevelWidth=1
LogLevel=0
</inputs>
</indicator>
</window>
</chart>
