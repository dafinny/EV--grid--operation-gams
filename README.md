# EV Grid Operations – GAMS Case Study

**Repository Name**: `ev-grid-operations-gams`  
**Author**: Dafinny Thanigaivel  
**Course**: ECE666 – Power System Operation (Winter 2025)  
**Institution**: University of Waterloo

---

## 🔍 Overview

This project explores the operational impact of Plug-in Electric Vehicles (PEVs) on power system performance using **GAMS-based Optimal Power Flow (OPF)** models. Through four distinct case studies, we simulate how PEVs—ranging from passive loads to active grid participants—affect generation cost, voltage stability, and transmission losses.

---

## ⚙️ Simulation Cases

| Case | Description |
|------|-------------|
| **Case 1** | Base case with no EVs integrated |
| **Case 2** | EVs modeled as static loads (charging only) |
| **Case 3** | V2G-enabled EVs supplying both real and reactive power |
| **Case 4** | V2G-enabled EVs supplying reactive power while charging (real power load) |


## 📊 Key Results Summary

| Metric                        | Case 1     | Case 2     | Case 3     | Case 4     |
|------------------------------|------------|------------|------------|------------|
| Total Generation Cost ($)    | 3453.30    | 3471.03    | 623.00     | 3456.71    |
| Total Transmission Loss (MW) | 23.00      | 23.03      | 48.29      | 2.29       |
| EV Charging Cost ($)         | —          | 15.29      | 0.00       | 15.29      |
| EV Real Power Discharge (MW) | 0.00       | 0.00       | -4.541     | 0.00       |
| EV Reactive Support (MVAr)   | 0.00       | 0.00       | 0.217      | 0.217      |

✅ **Case 3** results in the lowest cost  
✅ **Case 4** results in lowest losses and improved voltage conditions

---

## 📈 Core Technologies

- **GAMS** – General Algebraic Modeling System
- Power system modeling: Y-bus, voltage profiles, power flows
- EV load modeling: static charging, V2G discharging, reactive power injection
- Economic optimization using marginal cost and Lagrange multipliers

---

## 📑 Report Highlights

- Analysis based on IEEE 5-bus test system  
- All case results validated with power flow, cost, and marginal cost outputs  
- Discussions on trade-offs between cost reduction vs system losses  
- Reactive marginal prices help locate voltage stress zones  

📄 Full PDF report: [`ECE_666__Dafinny_Thanigaivel-5.pdf`](report/ECE_666__Dafinny_Thanigaivel-5.pdf)


---

## 📚 References

This work builds on academic contributions from:

- Hu et al. (Distributed MPC for V2G)
- Liu et al. (EV-based Frequency Regulation)
- Mouli et al. (PV-EV Coordination)
- Zhong et al. (Topology-aware V2G Trading)
- Valizadeh, Li & Hu, and others — [See full reference list in report](./ECE_666__Dafinny_Thanigaivel.pdf)

---

## 📫 Contact

For feedback or questions:  
📧 **dthaniga@uwaterloo.ca**

---

## 🛡️ License

This project is shared for academic purposes only. Reuse permitted with citation. Please respect institutional academic integrity policies.

