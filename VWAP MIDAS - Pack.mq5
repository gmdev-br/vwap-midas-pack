//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "VWAP Midas Pack"

#property indicator_chart_window
#property indicator_buffers 26
#property indicator_plots   26

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_method {
   Close,
   Open,
   High,
   Low,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted, // Weighted Close (HLCC/4)
   New // New
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input int                              IndicatorId = 1;                       // VWAP Id  (must be unique)
input int                              VwapCount    = 1;                      // VWAP count
input PRICE_method                     method    = Typical;                   // Price Calculation method
input bool                             onlyBuy = true;
input color                            vwapColor = clrYellow;                   // VWAP Color
input int                              arrowSize = 1;                         // Arrow Size
input int                              espessura_linha = 2;                   // Espessura das linhas
input ENUM_LINE_STYLE                  estiloLinha = STYLE_DASHDOT;           // Estilo da linha
input ENUM_ARROW_ANCHOR                Anchor    = ANCHOR_TOP;                // Arrow Anchor Point
input ENUM_APPLIED_VOLUME              applied_volume = VOLUME_REAL;          // tipo de volume
input int                              WaitMilliseconds  = 20000;              // Timer (milliseconds) for recalculation
input bool                       debug = false;
input bool espelhamento = true;
input bool bandas = false;
input bool modoHistorico = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- indicator buffers
double         vwapBuffer1[], vwapBuffer2[], vwapBuffer3[], vwapBuffer4[], vwapBuffer5[], vwapBuffer6[], vwapBuffer7[], vwapBuffer8[], vwapBuffer9[], vwapBuffer10[];
double         vwapBuffer11[], vwapBuffer12[], vwapBuffer13[], vwapBuffer14[], vwapBuffer15[], vwapBuffer16[], vwapBuffer17[], vwapBuffer18[], vwapBuffer19[], vwapBuffer20[];
double         vwapBufferMirror1[], vwapBufferMirror2[], vwapBufferMirror3[], vwapBufferMirror4[], vwapBufferMirror5[], vwapBufferMirror6[];
int            startVWAP1 = 0, startVWAP2 = 0, startVWAP3 = 0, startVWAP4 = 0, startVWAP5 = 0, startVWAP6 = 0, startVWAP7 = 0, startVWAP8 = 0, startVWAP9 = 0, startVWAP10 = 0;
int            startVWAP11 = 0, startVWAP12 = 0, startVWAP13 = 0, startVWAP14 = 0, startVWAP15 = 0, startVWAP16 = 0, startVWAP17 = 0, startVWAP18 = 0, startVWAP19 = 0, startVWAP20 = 0;
string         indicatorPrefix, prefix1, prefix2, prefix3, prefix4, prefix5, prefix6, prefix7, prefix8, prefix9, prefix10;
string         prefix11, prefix12, prefix13, prefix14, prefix15, prefix16, prefix17, prefix18, prefix19, prefix20;
datetime       arrayTime[];
double         arrayOpen[], arrayHigh[], arrayLow[], arrayClose[];
string         prefix[];
long           VolumeBuffer[];
int            startVwap[];
long           obj_time;
bool           first = true;
int            barras_visiveis, teste;
datetime       Hposition;
double         Vposition;
int            totalRates;
string         tipo_vwap = "Typical";
int            vwapNumber = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   indicatorPrefix = IndicatorId;

   SetIndexBuffer(0, vwapBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, vwapBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, vwapBuffer3, INDICATOR_DATA);
   SetIndexBuffer(3, vwapBuffer4, INDICATOR_DATA);
   SetIndexBuffer(4, vwapBuffer5, INDICATOR_DATA);
   SetIndexBuffer(5, vwapBuffer6, INDICATOR_DATA);
   SetIndexBuffer(6, vwapBuffer7, INDICATOR_DATA);
   SetIndexBuffer(7, vwapBuffer8, INDICATOR_DATA);
   SetIndexBuffer(8, vwapBuffer9, INDICATOR_DATA);
   SetIndexBuffer(9, vwapBuffer10, INDICATOR_DATA);
   SetIndexBuffer(10, vwapBuffer11, INDICATOR_DATA);
   SetIndexBuffer(11, vwapBuffer12, INDICATOR_DATA);
   SetIndexBuffer(12, vwapBuffer13, INDICATOR_DATA);
   SetIndexBuffer(13, vwapBuffer14, INDICATOR_DATA);
   SetIndexBuffer(14, vwapBuffer15, INDICATOR_DATA);
   SetIndexBuffer(15, vwapBuffer16, INDICATOR_DATA);
   SetIndexBuffer(16, vwapBuffer17, INDICATOR_DATA);
   SetIndexBuffer(17, vwapBuffer18, INDICATOR_DATA);
   SetIndexBuffer(18, vwapBuffer19, INDICATOR_DATA);
   SetIndexBuffer(19, vwapBuffer20, INDICATOR_DATA);
   SetIndexBuffer(20, vwapBufferMirror1, INDICATOR_DATA);
   SetIndexBuffer(21, vwapBufferMirror2, INDICATOR_DATA);
   SetIndexBuffer(22, vwapBufferMirror3, INDICATOR_DATA);
   SetIndexBuffer(23, vwapBufferMirror4, INDICATOR_DATA);
   SetIndexBuffer(24, vwapBufferMirror5, INDICATOR_DATA);
   SetIndexBuffer(25, vwapBufferMirror6, INDICATOR_DATA);

   ArrayResize(prefix, 20);
   ArrayResize(startVwap, 20);
   for (int i = 0; i <= 19; i++) {
      prefix[i] = "VWAP_" + indicatorPrefix + "_" + (i + 1);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "VWAP" + i);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, estiloLinha);
   }

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(10, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(13, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(14, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(15, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(16, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(17, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(18, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(19, PLOT_LINE_COLOR, vwapColor);
   PlotIndexSetInteger(20, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetInteger(21, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetInteger(22, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetInteger(23, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetInteger(24, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetInteger(25, PLOT_LINE_COLOR, clrWhite);

   PlotIndexSetDouble(20, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(20, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(20, PLOT_LABEL, "VWAP Mirror1");
   PlotIndexSetDouble(21, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(21, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(21, PLOT_LABEL, "VWAP Mirror2");
   PlotIndexSetDouble(22, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(22, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(22, PLOT_LABEL, "VWAP Mirror3");
   PlotIndexSetDouble(23, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(23, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(23, PLOT_LABEL, "VWAP Mirror4");
   PlotIndexSetDouble(24, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(24, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(24, PLOT_LABEL, "VWAP Mirror5");
   PlotIndexSetDouble(25, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(25, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(25, PLOT_LABEL, "VWAP Mirror6");

   ArrayInitialize(startVwap, 0);

   if (VwapCount == 0) {
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);
      ArrayInitialize(vwapBufferMirror1, 0);
      ArrayInitialize(vwapBufferMirror2, 0);
      ArrayInitialize(vwapBufferMirror3, 0);
      ArrayInitialize(vwapBufferMirror4, 0);
      ArrayInitialize(vwapBufferMirror5, 0);
      ArrayInitialize(vwapBufferMirror6, 0);
   } else {
      if (VwapCount == 1) {
         ArrayInitialize(vwapBuffer1, 0);
      } else  if (VwapCount == 2) {
         ArrayInitialize(vwapBuffer2, 0);
      } else  if (VwapCount == 3) {
         ArrayInitialize(vwapBuffer3, 0);
      } else  if (VwapCount == 4) {
         ArrayInitialize(vwapBuffer4, 0);
      } else  if (VwapCount == 5) {
         ArrayInitialize(vwapBuffer5, 0);
      } else  if (VwapCount == 6) {
         ArrayInitialize(vwapBuffer6, 0);
      } else  if (VwapCount == 7) {
         ArrayInitialize(vwapBuffer7, 0);
      } else  if (VwapCount == 8) {
         ArrayInitialize(vwapBuffer8, 0);
      } else  if (VwapCount == 9) {
         ArrayInitialize(vwapBuffer9, 0);
      } else  if (VwapCount == 10) {
         ArrayInitialize(vwapBuffer10, 0);
      } else  if (VwapCount == 11) {
         ArrayInitialize(vwapBuffer11, 0);
      } else  if (VwapCount == 12) {
         ArrayInitialize(vwapBuffer12, 0);
      } else  if (VwapCount == 13) {
         ArrayInitialize(vwapBuffer13, 0);
      } else  if (VwapCount == 14) {
         ArrayInitialize(vwapBuffer14, 0);
      } else  if (VwapCount == 15) {
         ArrayInitialize(vwapBuffer15, 0);
      } else  if (VwapCount == 16) {
         ArrayInitialize(vwapBuffer16, 0);
      } else  if (VwapCount == 17) {
         ArrayInitialize(vwapBuffer17, 0);
      } else  if (VwapCount == 18) {
         ArrayInitialize(vwapBuffer18, 0);
      } else  if (VwapCount == 19) {
         ArrayInitialize(vwapBuffer19, 0);
      } else  if (VwapCount == 20) {
         ArrayInitialize(vwapBuffer20, 0);
      }
   }

   for (int i = 0; i < VwapCount; i++) {
      criaVwap(prefix[i]);
   }

   ChartRedraw();
   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);



   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void criaVwap(string pprefix) {

   datetime timeArrow = GetObjectTime1(pprefix);
   if (timeArrow == 0 && VwapCount >= 1) {
      CreateObject(pprefix);
      //CustomizeObject(pprefix);
   } else if (timeArrow != 0 && VwapCount >= 1) {
      CustomizeObject(pprefix);
   } else if (timeArrow != 0 && VwapCount < 1) {
      ObjectDelete(0, pprefix);
   }

}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   delete(_updateTimer);

   if(reason == REASON_REMOVE) {
      for (int i = 0; i <= 19; i++) {
         ObjectDelete(0, "VWAP_" + indicatorPrefix + "_" + i);
         ObjectDelete(0, "VWAP_" + indicatorPrefix + "_" + method + "_" + i + "_line");
      }
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return(1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   vwapNumber = 0;
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   totalRates = SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_BARS_COUNT);

   prepareData(vwapNumber);

   if (vwapNumber == 0) {
      ArrayInitialize(vwapBuffer1, 0);
      ArrayInitialize(vwapBuffer2, 0);
      ArrayInitialize(vwapBuffer3, 0);
      ArrayInitialize(vwapBuffer4, 0);
      ArrayInitialize(vwapBuffer5, 0);
      ArrayInitialize(vwapBuffer6, 0);
      ArrayInitialize(vwapBuffer7, 0);
      ArrayInitialize(vwapBuffer8, 0);
      ArrayInitialize(vwapBuffer9, 0);
      ArrayInitialize(vwapBuffer10, 0);
      ArrayInitialize(vwapBuffer11, 0);
      ArrayInitialize(vwapBuffer12, 0);
      ArrayInitialize(vwapBuffer13, 0);
      ArrayInitialize(vwapBuffer14, 0);
      ArrayInitialize(vwapBuffer15, 0);
      ArrayInitialize(vwapBuffer16, 0);
      ArrayInitialize(vwapBuffer17, 0);
      ArrayInitialize(vwapBuffer18, 0);
      ArrayInitialize(vwapBuffer19, 0);
      ArrayInitialize(vwapBuffer20, 0);
      ArrayInitialize(vwapBufferMirror1, 0);
      ArrayInitialize(vwapBufferMirror2, 0);
      ArrayInitialize(vwapBufferMirror3, 0);
      ArrayInitialize(vwapBufferMirror4, 0);
      ArrayInitialize(vwapBufferMirror5, 0);
      ArrayInitialize(vwapBufferMirror6, 0);

      if (VwapCount >= 1) CalculateVWAP(startVwap[0], vwapBuffer1);
      if (VwapCount >= 2) CalculateVWAP(startVwap[1], vwapBuffer2);
      if (VwapCount >= 3) CalculateVWAP(startVwap[2], vwapBuffer3);
      if (VwapCount >= 4) CalculateVWAP(startVwap[3], vwapBuffer4);
      if (VwapCount >= 5) CalculateVWAP(startVwap[4], vwapBuffer5);
      if (VwapCount >= 6) CalculateVWAP(startVwap[5], vwapBuffer6);
      if (VwapCount >= 7) CalculateVWAP(startVwap[6], vwapBuffer7);
      if (VwapCount >= 8) CalculateVWAP(startVwap[7], vwapBuffer8);
      if (VwapCount >= 9) CalculateVWAP(startVwap[8], vwapBuffer9);
      if (VwapCount >= 10) CalculateVWAP(startVwap[9], vwapBuffer10);
      if (VwapCount >= 11) CalculateVWAP(startVwap[10], vwapBuffer11);
      if (VwapCount >= 12) CalculateVWAP(startVwap[11], vwapBuffer12);
      if (VwapCount >= 13) CalculateVWAP(startVwap[12], vwapBuffer13);
      if (VwapCount >= 14) CalculateVWAP(startVwap[13], vwapBuffer14);
      if (VwapCount >= 15) CalculateVWAP(startVwap[14], vwapBuffer15);
      if (VwapCount >= 16) CalculateVWAP(startVwap[15], vwapBuffer16);
      if (VwapCount >= 17) CalculateVWAP(startVwap[16], vwapBuffer17);
      if (VwapCount >= 18) CalculateVWAP(startVwap[17], vwapBuffer18);
      if (VwapCount >= 19) CalculateVWAP(startVwap[18], vwapBuffer19);
      if (VwapCount >= 20) CalculateVWAP(startVwap[19], vwapBuffer20);
   } else {
      if (vwapNumber == 1) {
         ArrayInitialize(vwapBuffer1, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer1);
      } else  if (vwapNumber == 2) {
         ArrayInitialize(vwapBuffer2, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer2);
      } else  if (vwapNumber == 3) {
         ArrayInitialize(vwapBuffer3, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer3);
      } else  if (vwapNumber == 4) {
         ArrayInitialize(vwapBuffer4, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer4);
      } else  if (vwapNumber == 5) {
         ArrayInitialize(vwapBuffer5, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer5);
      } else  if (vwapNumber == 6) {
         ArrayInitialize(vwapBuffer6, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer6);
      } else  if (vwapNumber == 7) {
         ArrayInitialize(vwapBuffer7, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer7);
      } else  if (vwapNumber == 8) {
         ArrayInitialize(vwapBuffer8, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer8);
      } else  if (vwapNumber == 9) {
         ArrayInitialize(vwapBuffer9, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer9);
      } else  if (vwapNumber == 10) {
         ArrayInitialize(vwapBuffer10, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer10);
      } else  if (vwapNumber == 11) {
         ArrayInitialize(vwapBuffer11, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer11);
      } else  if (vwapNumber == 12) {
         ArrayInitialize(vwapBuffer12, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer12);
      } else  if (vwapNumber == 13) {
         ArrayInitialize(vwapBuffer13, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer13);
      } else  if (vwapNumber == 14) {
         ArrayInitialize(vwapBuffer14, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer14);
      } else  if (vwapNumber == 15) {
         ArrayInitialize(vwapBuffer15, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer15);
      } else  if (vwapNumber == 16) {
         ArrayInitialize(vwapBuffer16, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer16);
      } else  if (vwapNumber == 17) {
         ArrayInitialize(vwapBuffer17, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer17);
      } else  if (vwapNumber == 18) {
         ArrayInitialize(vwapBuffer18, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer18);
      } else  if (vwapNumber == 19) {
         ArrayInitialize(vwapBuffer19, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer19);
      } else  if (vwapNumber == 20) {
         ArrayInitialize(vwapBuffer20, 0);
         CalculateVWAP(startVwap[vwapNumber - 1], vwapBuffer20);
      }

      string teste = "VWAP_" + indicatorPrefix + "_" + method + "_" + (vwapNumber + 1);
      if (startVwap[vwapNumber - 1] - 1 > 0) {

         double valor = 0;
         if(method == Open) {
            valor    = arrayOpen[startVwap[vwapNumber - 1] - 1];
         } else if(method == High) {
            valor    = arrayHigh[startVwap[vwapNumber - 1] - 1];
         } else if(method == Low) {
            valor    = arrayLow[startVwap[vwapNumber - 1] - 1];
         } else if(method == Median) {
            valor    = (arrayHigh[startVwap[vwapNumber - 1] - 1] +
                        arrayLow[startVwap[vwapNumber - 1] - 1]) / 2;
         } else if(method == Typical) {
            valor    = (arrayHigh[startVwap[vwapNumber - 1] - 1] +
                        arrayLow[startVwap[vwapNumber - 1] - 1] +
                        arrayClose[startVwap[vwapNumber - 1] - 1]) / 3;
         } else if(method == Weighted) {
            valor    = (arrayHigh[startVwap[vwapNumber - 1] - 1] +
                        arrayLow[startVwap[vwapNumber - 1] - 1] +
                        arrayClose[startVwap[vwapNumber - 1] - 1] +
                        arrayClose[startVwap[vwapNumber - 1] - 1]) / 3;
         } else {
            valor    = arrayClose[startVwap[vwapNumber - 1] - 1];
         }


         ObjectDelete(0, teste + "_line");
         ObjectCreate(0, teste + "_line", OBJ_TREND, 0, iTime(NULL, PERIOD_CURRENT, startVwap[vwapNumber - 1] - 1), valor,
                      iTime(NULL, PERIOD_CURRENT, 0) + PeriodSeconds(PERIOD_CURRENT) * 20, valor);
         ObjectSetInteger(0, teste + "_line", OBJPROP_COLOR, vwapColor);
         ObjectSetInteger(0, teste + "_line", OBJPROP_WIDTH, espessura_linha);
         ObjectSetInteger(0, teste + "_line", OBJPROP_STYLE, STYLE_DASHDOTDOT);
      } else {
         ObjectDelete(0, teste + "_line");
      }
   }

   ChartRedraw();

//ArrayFree(arrayClose);
//ArrayFree(arrayHigh);
//ArrayFree(arrayLow);
//ArrayFree(arrayOpen);
//ArrayFree(arrayTime);
//ArrayFree(VolumeBuffer);
   return(true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void prepareData(int count = 0) {

   if (count == 0) {
      for (int i = 0; i <= VwapCount - 1; i++) {
         startVwap[i] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[i], OBJPROP_TIME)) + 1;
      }
   } else {
      if (count == 1) {
         startVwap[0] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[0], OBJPROP_TIME)) + 1;
      } else  if (count == 2) {
         startVwap[1] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[1], OBJPROP_TIME)) + 1;
      } else  if (count == 3) {
         startVwap[2] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[2], OBJPROP_TIME)) + 1;
      } else  if (count == 4) {
         startVwap[3] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[3], OBJPROP_TIME)) + 1;
      } else  if (count == 5) {
         startVwap[4] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[4], OBJPROP_TIME)) + 1;
      } else  if (count == 6) {
         startVwap[5] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[5], OBJPROP_TIME)) + 1;
      } else  if (count == 7) {
         startVwap[6] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[6], OBJPROP_TIME)) + 1;
      } else  if (count == 8) {
         startVwap[7] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[7], OBJPROP_TIME)) + 1;
      } else  if (count == 9) {
         startVwap[8] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[8], OBJPROP_TIME)) + 1;
      } else  if (count == 10) {
         startVwap[9] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[9], OBJPROP_TIME)) + 1;
      } else  if (count == 11) {
         startVwap[10] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[10], OBJPROP_TIME)) + 1;
      } else  if (count == 12) {
         startVwap[11] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[11], OBJPROP_TIME)) + 1;
      } else  if (count == 13) {
         startVwap[12] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[12], OBJPROP_TIME)) + 1;
      } else  if (count == 14) {
         startVwap[13] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[13], OBJPROP_TIME)) + 1;
      } else  if (count == 15) {
         startVwap[14] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[14], OBJPROP_TIME)) + 1;
      } else  if (count == 16) {
         startVwap[15] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[15], OBJPROP_TIME)) + 1;
      } else  if (count == 17) {
         startVwap[16] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[16], OBJPROP_TIME)) + 1;
      } else  if (count == 18) {
         startVwap[17] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[17], OBJPROP_TIME)) + 1;
      } else  if (count == 19) {
         startVwap[18] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[18], OBJPROP_TIME)) + 1;
      } else  if (count == 20) {
         startVwap[19] = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, prefix[19], OBJPROP_TIME)) + 1;
      }
   }

   int maxIndex = startVwap[ArrayMaximum(startVwap)];
//Print("startVWAP10: " + startVWAP10);
   if (applied_volume == VOLUME_TICK) {
      teste = CopyTickVolume(_Symbol, 0, 0, maxIndex, VolumeBuffer);
   } else if (applied_volume == VOLUME_REAL) {
      teste = CopyRealVolume(_Symbol, 0, 0, maxIndex, VolumeBuffer);
   }
   teste = CopyLow(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayLow);
   teste = CopyClose(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayClose);
   teste = CopyHigh(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayHigh);
   teste = CopyOpen(_Symbol, PERIOD_CURRENT, 0, maxIndex, arrayOpen);

   ArraySetAsSeries(arrayOpen, true);
   ArraySetAsSeries(arrayLow, true);
   ArraySetAsSeries(arrayClose, true);
   ArraySetAsSeries(arrayHigh, true);
   ArraySetAsSeries(VolumeBuffer, true);

   ArraySetAsSeries(vwapBuffer1, true);
   ArraySetAsSeries(vwapBuffer2, true);
   ArraySetAsSeries(vwapBuffer3, true);
   ArraySetAsSeries(vwapBuffer4, true);
   ArraySetAsSeries(vwapBuffer5, true);
   ArraySetAsSeries(vwapBuffer6, true);
   ArraySetAsSeries(vwapBuffer7, true);
   ArraySetAsSeries(vwapBuffer8, true);
   ArraySetAsSeries(vwapBuffer9, true);
   ArraySetAsSeries(vwapBuffer10, true);
   ArraySetAsSeries(vwapBuffer11, true);
   ArraySetAsSeries(vwapBuffer12, true);
   ArraySetAsSeries(vwapBuffer13, true);
   ArraySetAsSeries(vwapBuffer14, true);
   ArraySetAsSeries(vwapBuffer15, true);
   ArraySetAsSeries(vwapBuffer16, true);
   ArraySetAsSeries(vwapBuffer17, true);
   ArraySetAsSeries(vwapBuffer18, true);
   ArraySetAsSeries(vwapBuffer19, true);
   ArraySetAsSeries(vwapBuffer20, true);
   ArraySetAsSeries(vwapBufferMirror1, true);
   ArraySetAsSeries(vwapBufferMirror2, true);
   ArraySetAsSeries(vwapBufferMirror3, true);
   ArraySetAsSeries(vwapBufferMirror4, true);
   ArraySetAsSeries(vwapBufferMirror5, true);
   ArraySetAsSeries(vwapBufferMirror6, true);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVWAP(int index, double &targetBuffer[]) {

   double sumPrice = 0, sumVol = 0, vwap = 0;

   if(method == Open) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayOpen[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == High) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayHigh[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
         if (bandas) {
            if (espelhamento) {
               vwapBufferMirror1[i] = arrayHigh[index - 1] + 0.25 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               vwapBufferMirror2[i] = arrayHigh[index - 1] + 0.75 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               vwapBufferMirror3[i] = arrayHigh[index - 1] + 0.5 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               vwapBufferMirror4[i] = arrayHigh[index - 1] + 1.25 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               vwapBufferMirror5[i] = arrayHigh[index - 1] + 1 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               vwapBufferMirror6[i] = arrayHigh[index - 1] + 1.5 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
               //vwapBufferMirror1[i] = arrayHigh[index - 1] + 3 * MathAbs(arrayHigh[index - 1] - targetBuffer[i]);
            } else {
               vwapBufferMirror1[i] = targetBuffer[i] + 0.25 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
               vwapBufferMirror2[i] = targetBuffer[i] + 0.75 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
               vwapBufferMirror3[i] = targetBuffer[i] + 0.5 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
               vwapBufferMirror4[i] = targetBuffer[i] - 0.25 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
               vwapBufferMirror5[i] = targetBuffer[i] - 0.75 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
               vwapBufferMirror6[i] = targetBuffer[i] - 0.5 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            }
         }
      }
   } else if(method == Low) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayLow[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
         //vwapBufferMirror1[i] = arrayLow[index - 1] - 1 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
         //vwapBufferMirror2[i] = arrayLow[index - 1] - 2 *MathAbs(arrayLow[index - 1] - targetBuffer[i]);
         //vwapBufferMirror3[i] = arrayLow[index - 1] - 0.5 *MathAbs(arrayLow[index - 1] - targetBuffer[i]);
         if (bandas) {
            vwapBufferMirror1[i] = targetBuffer[i] + 0.25 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            vwapBufferMirror2[i] = targetBuffer[i] + 0.75 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            vwapBufferMirror3[i] = targetBuffer[i] + 0.5 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            vwapBufferMirror4[i] = targetBuffer[i] - 0.25 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            vwapBufferMirror5[i] = targetBuffer[i] - 0.75 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
            vwapBufferMirror6[i] = targetBuffer[i] - 0.5 * MathAbs(arrayLow[index - 1] - targetBuffer[i]);
         }
      }
   } else if(method == Median) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i]) / 2) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else if(method == Typical) {
      for(int i = index - 1 ; i >= 0; i--) {
         if (!onlyBuy) {
            sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
            sumVol      += VolumeBuffer[i];
            targetBuffer[i] = sumPrice / sumVol;
            if (bandas) {
               vwapBufferMirror1[i] = targetBuffer[i] + 0.25 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
               vwapBufferMirror2[i] = targetBuffer[i] + 0.75 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
               vwapBufferMirror3[i] = targetBuffer[i] + 0.5 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
               vwapBufferMirror4[i] = targetBuffer[i] - 0.25 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
               vwapBufferMirror5[i] = targetBuffer[i] - 0.75 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
               vwapBufferMirror6[i] = targetBuffer[i] - 0.5 * MathAbs(((arrayHigh[index - 1] + arrayLow[index - 1] + arrayClose[index - 1]) / 3) - targetBuffer[i]);
            }
         } else {
            if (arrayClose[i] <= arrayOpen[i]) {
               sumPrice    += -1*((arrayHigh[i] + arrayLow[i] + arrayClose[i]) / 3) * VolumeBuffer[i];
               sumVol      += -1*VolumeBuffer[i];
            } else {
               sumPrice    += 0;
               sumVol      += 0;
            }
            targetBuffer[i] = sumPrice / sumVol;
         }
      }
   } else if(method == Weighted) {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += ((arrayHigh[i] + arrayLow[i] + arrayClose[i] + arrayClose[i]) / 4) * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   } else {
      for(int i = index - 1 ; i >= 0; i--) {
         sumPrice    += arrayClose[i] * VolumeBuffer[i];
         sumVol      += VolumeBuffer[i];
         targetBuffer[i] = sumPrice / sumVol;
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateObject(string name) {

   barras_visiveis = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);

   int      offset = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR) - barras_visiveis / 2;
   Hposition = iTime(_Symbol, PERIOD_CURRENT, offset);

   if(Anchor == ANCHOR_TOP)
      Vposition = iLow(_Symbol, PERIOD_CURRENT, offset) - SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   else
      Vposition = iHigh(_Symbol, PERIOD_CURRENT, offset) + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   if (!modoHistorico) {
      ObjectCreate(0, name, OBJ_ARROW, 0, Hposition, Vposition);
   } else {
      ObjectCreate(0, name, OBJ_ARROW, 0, Hposition, 0);
   }

   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 233);
//ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, vwapColor);
//ObjectSetInteger(0, name, OBJPROP_FILL, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção
//--- é verdade por padrão, tornando possível destacar e mover o objeto
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 100);
   ObjectSetInteger(0, name, OBJPROP_FILL, true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomizeObject(string name) {

   ArrayInitialize(vwapBuffer1, 0);
   ArrayInitialize(vwapBuffer2, 0);
   ArrayInitialize(vwapBuffer3, 0);
   ArrayInitialize(vwapBuffer4, 0);
   ArrayInitialize(vwapBuffer5, 0);
   ArrayInitialize(vwapBuffer6, 0);
   ArrayInitialize(vwapBuffer7, 0);
   ArrayInitialize(vwapBuffer8, 0);
   ArrayInitialize(vwapBuffer9, 0);
   ArrayInitialize(vwapBuffer10, 0);
   ArrayInitialize(vwapBuffer11, 0);
   ArrayInitialize(vwapBuffer12, 0);
   ArrayInitialize(vwapBuffer13, 0);
   ArrayInitialize(vwapBuffer14, 0);
   ArrayInitialize(vwapBuffer15, 0);
   ArrayInitialize(vwapBuffer16, 0);
   ArrayInitialize(vwapBuffer17, 0);
   ArrayInitialize(vwapBuffer18, 0);
   ArrayInitialize(vwapBuffer19, 0);
   ArrayInitialize(vwapBuffer20, 0);
   ArrayInitialize(vwapBufferMirror1, 0);
   ArrayInitialize(vwapBufferMirror2, 0);
   ArrayInitialize(vwapBufferMirror3, 0);
   ArrayInitialize(vwapBufferMirror4, 0);
   ArrayInitialize(vwapBufferMirror5, 0);
   ArrayInitialize(vwapBufferMirror6, 0);

   int posicao = iBarShift(_Symbol, PERIOD_CURRENT, ObjectGetInteger(0, name, OBJPROP_TIME));
   double preco = ObjectGetDouble(0, name, OBJPROP_PRICE);
   if (preco == 0 && !modoHistorico) {
      if(Anchor == ANCHOR_TOP)
         preco = iLow(_Symbol, PERIOD_CURRENT, posicao);
      else
         preco = iHigh(_Symbol, PERIOD_CURRENT, posicao);

      Hposition = iTime(_Symbol, PERIOD_CURRENT, posicao);
      ObjectMove(0, name, 0, Hposition, preco);
   }

   if (modoHistorico)
      ObjectMove(0, name, 0, Hposition, 0);

   ObjectSetInteger(0, name, OBJPROP_COLOR, vwapColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, arrowSize);

   ObjectSetInteger(0, name, OBJPROP_ANCHOR, Anchor);

   if(Anchor == ANCHOR_TOP)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 233);

   if(Anchor == ANCHOR_BOTTOM)
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 234);

//ObjectSetInteger(0, name, OBJPROP_COLOR, vwapColor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {
 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }
};

bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {
   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();

      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      if (debug) Print("VWAP Midas " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator Chart Event function                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long & lparam, const double & dparam, const string & sparam) {

   if(id == CHARTEVENT_OBJECT_DRAG) {
      vwapNumber = 0;
      if (sparam == prefix[0]) vwapNumber = 1;
      else if (sparam == prefix[1]) vwapNumber = 2;
      else if (sparam == prefix[2]) vwapNumber = 3;
      else if (sparam == prefix[3]) vwapNumber = 4;
      else if (sparam == prefix[4]) vwapNumber = 5;
      else if (sparam == prefix[5]) vwapNumber = 6;
      else if (sparam == prefix[6]) vwapNumber = 7;
      else if (sparam == prefix[7]) vwapNumber = 8;
      else if (sparam == prefix[8]) vwapNumber = 9;
      else if (sparam == prefix[9]) vwapNumber = 10;
      else if (sparam == prefix[10]) vwapNumber = 11;
      else if (sparam == prefix[11]) vwapNumber = 12;
      else if (sparam == prefix[12]) vwapNumber = 13;
      else if (sparam == prefix[13]) vwapNumber = 14;
      else if (sparam == prefix[14]) vwapNumber = 15;
      else if (sparam == prefix[15]) vwapNumber = 16;
      else if (sparam == prefix[16]) vwapNumber = 17;
      else if (sparam == prefix[17]) vwapNumber = 18;
      else if (sparam == prefix[18]) vwapNumber = 19;
      else if (sparam == prefix[19]) vwapNumber = 20;
      else vwapNumber = 0;



      _lastOK = false;
      CheckTimer();
   }

   if(id == CHARTEVENT_CHART_CHANGE) {
      _lastOK = true;
      CheckTimer();
   }
}

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}
//
////+------------------------------------------------------------------+
////| iBarShift2() function                                             |
////+------------------------------------------------------------------+
//int iBarShift2(string symbol, ENUM_TIMEFRAMES timeframe, datetime time) {
//   if(time < 0) {
//      return(-1);
//   }
//   datetime Arr[], time1;
//
//   time1 = (datetime)SeriesInfoInteger(symbol, timeframe, SERIES_LASTBAR_DATE);
//
//   if(CopyTime(symbol, timeframe, time, time1, Arr) > 0) {
//      int size = ArraySize(Arr);
//      return(size - 1);
//   } else {
//      return(-1);
//   }
//}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetObjectTime1(const string name) {
   datetime time;

   if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, time))
      return(0);

   return(time);
}

//+------------------------------------------------------------------+
