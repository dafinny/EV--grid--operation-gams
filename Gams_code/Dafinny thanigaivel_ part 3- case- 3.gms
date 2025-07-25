*----------------------------------------------------------
* The OPTIMAL POWER FLOW PROBLEM
*----------------------------------------------------------


*----------------------------------------------------------
* Notations Used
*----------------
*  A generator cost function is represented as a quadratic polynomial
*  as follows: A*P**2 + B*P + C
*  A:     Quadratic component of cost function, in dollars per MW**2-h
*  B:     Linear component of cost function, in dollars per MWh
*  C:     Constant component of cost function, in dollars per hour
*  PMax:  Generating unit maximum capacity in MW
*  PMin:  Generating unit minimum capacity in MW
*  QMax:  Generating unit maximum reactive power capacity in MVAr
*  QPMin: Generating unit minimum capacity in MW
*  Gen:   Denotes the set of generating units
*  Load:  Denotes the total load in the system in MW
*----------------------------------------------------------


Option solprint = ON;
Option sysout   = ON;
Option limrow   =  6;
Option limcol   =  6;
Option decimals =  8 ;


set i buses/1*5/ ;
set evbuses /3,5/; 
alias (i,j) ;

Set Gen(i)  PV bus /1,2,4/
    Load(i) Load Buses /3, 5/
    Head1   Generator data headings / PMin, PMax, QMin, QMax, A, B, C/
    Head2   Line data table headings / Re, Xe, Ch /
    Head3   Demand data table headings / PDem, QDem /;

Set slack(i)/1/;

Scalar Base base MVA  /100 /;
Scalar phi            /3.141592654 /;
Variable P_EV(i), Q_EV(i);
Scalar C_ch /39/, C_dis /38.22/;
Parameter EV_Cost;
Scalar EVcount /28/;
Scalar        
  P_EV_kW     /7/        
  Q_EV_kVAr   /3.87/          
  PEVmax, QEVmax;        

PEVmax = (EVcount * P_EV_kW) / (Base * 1000);
QEVmax = (EVcount * Q_EV_kVAr) / (Base * 1000);
Variable P_EV_inj(i), P_EV_abs(i), Q_EV_inj(i), Q_EV_abs(i);

P_EV_inj.up(i)$evbuses(i) = PEVmax;
P_EV_abs.up(i)$evbuses(i) = PEVmax;
Q_EV_inj.up(i)$evbuses(i) = QEVmax;
Q_EV_abs.up(i)$evbuses(i) = QEVmax;




**********  DATA SECTION ****************************************

TABLE Generat(i,Head1)  generator data
   PMin     PMax   QMin      QMax         A       B       C
*    MW       MW   MVAR      MVAR

1    50      400    -50       150     0.003    2.45    10.5
2    50      350    -50       150     0.005    3.51    44.4
4    50      350    -50       150     0.006    3.89    40.6
;

*------- Convert generator data to per unit quantities ----------
Parameter PMx(i), PMn(i), QMx(i), QMn(i), Ac(i), Bc(i), Cc(i);

PMx(i) = Generat(i,"PMax")/Base;
PMn(i) = Generat(i,"PMin")/Base;
QMx(i) = Generat(i,"QMax")/Base;
QMn(i) = Generat(i,"QMin")/Base;

Ac(i)  = Generat(i,"A")*Base*Base;
Bc(i)  = Generat(i,"B")*Base;
Cc(i)  = Generat(i,"C");
*----------------------------------------------------------------

Table Demand(i,Head3)        Real and reactive power demand at bus i
               PDem       QDem
*              (MW)      (MVAr)
1               125         45
2               150         50
3               175         65
4               180         60
5               145         55
;


*------- Convert Demand data to per unit quantities ------------------
Parameter  PD(i), QD(i) ;
PD(i) = Demand(i,"PDem")/Base;
QD(i) = Demand(i,"QDem")/Base;


Variable P_EV_inj(i), P_EV_abs(i), Q_EV_inj(i), Q_EV_abs(i);
Variable P_EV(i), Q_EV(i);

*---------------------------------------------------------------------
display PD, QD;

Table LineData(i,j,Head2)
              Re        Xe        Ch
*         (p.u.)     (p.u.)   (p.u.)
1.2        0.021     0.065     0.032
1.3        0.074     0.233     0.025
2.3        0.062     0.195     0.023
2.4        0.055     0.154     0.025
2.5        0.036     0.123     0.015
3.4        0.012     0.045     0.105
4.5        0.037     0.145     0.025
;
********** DATA INPUT SECTION ENDS HERE ******************************

*---FORMATION OF THE Y-BUS MATRIX ------------------------------------
Parameter Z(i,j), GG(i,j), BB(i,j), YCL(i);
Parameter G(i,j), B(i,j), Y(i,j), ZI(i,j), Theta(i,j);

LineData(j,i,"Re")$(LineData(i,j,"Re") gt 0.00) = LineData(i,j,"Re");
LineData(j,i,"Xe")$(LineData(i,j,"Xe") gt 0.00) = LineData(i,j,"Xe");
LineData(j,i,"Ch")$(LineData(i,j,"Ch") gt 0.00) = LineData(i,j,"Ch");

Z(i,j) = (LineData(i,j,"Re"))**2 + (LineData(i,j,"Xe"))**2 ;
GG(i,j)$(Z(i,j) ne 0.00) = LineData(i,j,"Re")/z(i,j) ;

BB(i,j)$(Z(i,j) ne 0.00) = -LineData(i,j,"Xe")/Z(i,j);
BB(j,i)$(Z(i,j) ne 0.00) = -LineData(i,j,"Xe")/Z(i,j);

YCL(i) = sum(j, LineData(i,j,"Ch"));

B(i,i) = sum(j, BB(i,j)) + YCL(i);
G(i,i) = sum(j, GG(i,j));
G(i,j)$(ord(i) ne ord(j)) = -GG(i,j);
B(i,j)$(ord(i) ne ord(j)) = -BB(i,j);

Y(i,j) = sqrt(G(i,j)*G(i,j) + B(i,j)*B(i,j));

ZI(i,j)$(G(i,j) ne 0.00)  = abs(B(i,j))/abs(G(i,j)) ;

Theta(i,j) = arctan(ZI(i,j));
Theta(i,j)$((B(i,j) eq 0) and (G(i,j) gt 0)) = 0.0 ;
Theta(i,j)$((B(i,j) eq 0) and (G(i,j) lt 0))   = -0.5*phi ;
Theta(i,j)$((B(i,j) gt 0) and (G(i,j) gt 0))   = Theta(i,j) ;
Theta(i,j)$((B(i,j) lt 0) and (G(i,j) gt 0))   = 2*phi - Theta(i,j) ;
Theta(i,j)$((B(i,j) gt 0) and (G(i,j) lt 0))   = phi - Theta(i,j);
Theta(i,j)$((B(i,j) lt 0) and (G(i,j) lt 0))   = phi + Theta(i,j);
Theta(i,j)$((B(i,j) gt 0) and (G(i,j) eq 0))   = 0.5*phi;
Theta(i,j)$((B(i,j) lt 0) and (G(i,j) eq 0))   = -0.5*phi;
Theta(i,j)$((B(i,j) eq 0) and (G(i,j) eq 0))   = 0.0 ;

*---AT THIS POINT WE HAVE AVAILABLE Y(i,j) AND THETA(i,j)-------------
Display Y, Theta;

********* MODEL DEFINITION, SOLVE AND OUTPUT RESULTS SECTION *********
VARIABLES
V(i)           Voltage magnitude at bus i in per unit
Delta(i)       Voltage angle at bus i in radians
P(i)           Real power generation at bus i in per unit
Q(i)           Reactive power generation at bus i in per unit
Cost           Total system cost
Loss           Total system transmission loss
;


Parameter G(i,j);
G(i,j)    = -Y(i,j)*cos(Theta(i,j));

*-Initialization of Variables ------------------------------
V.l(i)        = 1.0 ;
Delta.l(i)    = 0.0 ;
Delta.fx("1") = 0;
*----------------------------------------------------------

EQUATIONS
CostFn       Total system generation cost in $
LossEq       Total system losses in per unit MW
Equn1(i)     Real power flow equation
Equn2(i)     Reactive power flow equation
VUp(i)       Bus voltage upper limit
VLo(i)       Bus Voltage lower limit
GenUp(i)     Generation upper limit
GenLo(i)     Generation lower limit
QGenUp(i)    Generation upper limit
QGenLo(i)    Generation lower limit
EV_PNetDef(i)    net power balance equation 
EV_QNetDef(i)
;

EV_Cost = sum(i$evbuses(i), C_ch * P_EV_abs.l(i)) - sum(i$evbuses(i), C_dis * P_EV_inj.l(i));



CostFn.. Cost =e= Sum(i, Ac(i)*P(i)*P(i)+Bc(i)*P(i)+Cc(i)) + EV_Cost;

LossEq..   Loss =e= 0.5*Sum((i,j), G(i,j)*(V(i)**2 + V(j)**2 - 2*V(i)*V(j)*cos(Delta(j)-Delta(i))));

Equn1(i)..  P(i) - PD(i) + P_EV(i) =e= sum(j, Y(i,j)*V(i)*V(j)*cos(Theta(i,j) + Delta(j) - Delta(i)));

Equn2(i)..  Q(i) - QD(i) + Q_EV(i) =e= -sum(j, Y(i,j)*V(i)*V(j)*sin(Theta(i,j) + Delta(j) - Delta(i)));


VUp(i)..   V(i) =l= 1.05;
VLo(i)..   V(i) =g= 0.95;

GenUp(i).. P(i) =l= PMx(i);
GenLo(i).. P(i) =g= PMn(i);

QGenUp(i).. Q(i) =l= QMx(i);
QGenLo(i).. Q(i) =g= QMn(i);

EV_PNetDef(i)$evbuses(i)..  P_EV(i) =e= P_EV_inj(i) - P_EV_abs(i);
EV_QNetDef(i)$evbuses(i)..  Q_EV(i) =e= Q_EV_inj(i) - Q_EV_abs(i);


MODEL OPF
/
CostFn
LossEq
Equn1
Equn2
VUp
VLo
GenUp
GenLo
QGenUp
QGenLo
EV_PNetDef
EV_QNetDef
/ ;



*-----------About Display of Solution---------------------------------
*  The final results will be available in the file 'OPFResult.put'
*  For additional information on the solution process, see the file
*    'OPF.lst'
*---------------------------------------------------------------------

File OPFResult;

Parameters PGx(i), QGx(i), CostA, CostB, LossA, LossB, MCPA(i),
           MCQA(i), MCPB(i), MCQB(i);

************************CASE-A **********************************
*  COST MINIMIZATION PROBLEM
*****************************************************************

SOLVE OPF using NLP Minimizing Cost;

Display V.l, Delta.l, P.l, Q.l, Cost.l, Loss.l;


CostA = Cost.l;
LossA = Loss.l*100;
PGx(i)  = P.l(i)*100;
QGx(i)  = Q.l(i)*100;
MCPA(i) = Equn1.m(i)/100;
MCQA(i) = Equn2.m(i)/100;
Parameter 
  PEV_MW(i), QEV_MVAr(i), PEV_Abs_MW(i), PEV_Inj_MW(i),
  QEV_Abs_MVAr(i), QEV_Inj_MVAr(i),
  PEV_Total, QEV_Total;

PEV_MW(i)       = P_EV.l(i)*Base;
QEV_MVAr(i)     = Q_EV.l(i)*Base;
PEV_Abs_MW(i)   = P_EV_abs.l(i)*Base;
PEV_Inj_MW(i)   = P_EV_inj.l(i)*Base;
QEV_Abs_MVAr(i) = Q_EV_abs.l(i)*Base;
QEV_Inj_MVAr(i) = Q_EV_inj.l(i)*Base;

PEV_Total = sum(i$evbuses(i), PEV_MW(i));
QEV_Total = sum(i$evbuses(i), QEV_MVAr(i));



Put OPFResult;
Put '*********************************************************************'; Put /;
Put ' FINAL OPF RESULTS - CASE 3 (EV Real & Reactive Support Enabled)'; Put /;
Put '*********************************************************************'; Put /;
Put ' Bus   P-Gen (MW)    Q-Gen (MVAr)    Real MC ($/MWh)    Reactive MC ($/MVArh)'; Put /;
Loop(i,
  Put '  ', i.TL:1, PGx(i):12:3, QGx(i):14:3, MCPA(i):18:3, MCQA(i):20:3; Put /;
);
Put /;

Put '-------------------- EV Contribution Summary ------------------------'; Put /;
Put ' Bus   P_EV (MW)   Q_EV (MVAr)   Charging (MW)   Discharging (MW)'; Put /;
Loop(i$evbuses(i),
  Put '  ', i.TL:1, PEV_MW(i):10:3, QEV_MVAr(i):15:3, PEV_Abs_MW(i):15:3, PEV_Inj_MW(i):17:3; Put /;
);

Put /;
Put '---------------------- System-Level Summary ------------------------'; Put /;
Put ' EV Total Real Power Support (MW):       ', PEV_Total:10:3; Put /;
Put ' EV Total Reactive Power Support (MVAr): ', QEV_Total:10:3; Put /;
Put ' EV Operational Cost ($):                ', EV_Cost:10:3; Put /;
Put ' Total Generation Cost ($):              ', CostA:10:3; Put /;
Put ' Total Transmission Loss (MW):           ', LossA:10:3; Put /;
Put '---------------------------------------------------------------------'; Put /;

************************Line real and reactive power flows for Case-A**********************************
* Notations Used
*****************
*  ReI:  Real part of current flowing in the line
*  ImI:  Imaginary part of current flowing in the line
*  ReP:  Real part of power flowing in the line
*  ImQ:  Imaginary part of power flowing in the line
*  CxP:  Complex power (S) flowing in the line
*****************************************************************

Parameter ReI(i,j), ImI(i,j), ReP(i,j), ImQ(i,j), CxP(i,j);

ReI(i,j) = V.l(j)*Y(i,j)*COS(Theta(i,j)+Delta.l(j)) - V.l(i)*Y(i,j)*COS(Theta(i,j)+Delta.l(i)) + V.l(i)*LineData(i,j,"ch")*SIN(Delta.l(i));

ImI(i,j) = V.l(j)*Y(i,j)*SIN(Theta(i,j)+Delta.l(j)) - V.l(i)*Y(i,j)*SIN(Theta(i,j)+Delta.l(i)) + V.l(i)*LineData(i,j,"ch")*COS(Delta.l(i));

ReP(i,j) = V.l(i)*(COS(Delta.l(i))*ReI(i,j)+SIN(Delta.l(i))*ImI(i,j));
ImQ(i,j) = V.l(i)*(SIN(Delta.l(i))*ReI(i,j)-COS(Delta.l(i))*ImI(i,j));
CxP(i,j) = sqrt(power(ReP(i,j),2) + power(ImQ(i,j),2));

display ReI, ImI, ReP, ImQ, CxP;