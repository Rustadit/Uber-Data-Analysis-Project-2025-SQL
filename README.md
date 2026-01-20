# Uber-Data-Analysis-Project-2025-SQL

## Table of Contents

* [Background Overview](#background-overview)
* [Data Structure and Overview](#data-structure-and-overview)
* [Assumptions and Limitations of the Project](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [License](#license)

---

## Background Overview

Uber has evolved into a multi-modal ride-sharing platform offering services across a range of vehicles. Operating across over 125 cities, Uber India faces a unique set of operational challenges, including high traffic congestion in urban centers, diverse customer demographics with varying price sensitivities and a massive, decentralized fleet of driver-partners. This complex and high-growth environment provides an ideal backdrop for a deep-dive analytical study.  
  
**Note**: This project utilizes a synthetically generated dataset modeled after real-world ride-sharing dynamics. It is designed specifically for portfolio demonstration to showcase advanced analytical capabilities in a complex business environment.


## **Data Structure and Overview**

This section of your portfolio provides a technical blueprint of the project. It describes how different data points—from a user’s click on a phone to a driver’s completed trip—are connected through a relational schema.

### **Entity Relationship Diagram (ERD)**

The project is built on a **Star Schema** architecture, designed for optimized analytical querying. At the center sits the transactional data, which is supported by various dimension tables providing context on users, drivers, geography, and vehicle types.

> ![Alt text](C:/code/Uberproject/entity_relationship_schema.jpg)
**

---

### **Table Descriptions**

The dataset consists of **seven interconnected tables**, capturing a 360-degree view of the Uber India marketplace in 2025.

#### **1. `Rides`**

* **Purpose:** The central transaction log containing every ride request made on the platform.
* **Key Metrics:** Ride Status (Completed, Cancelled, No Driver Found), Fare (INR), Distance (KM), and Timestamps.
* **Primary/Foreign Keys:** `Ride_ID` (PK), `Session_ID` (FK), `Driver_ID` (FK).

#### 2. `App_Sessions`

* **Purpose:** Tracks the "entry point" of every user. Every time a user opens the app, a unique session is created.
* **Key Metrics:** Device Type (iOS, Android, Web), Session Start/End times.
* **Primary/Foreign Keys:** `Session_ID` (PK), `User_ID` (FK).

#### 3. `App_Events`

* **Purpose:** A granular log of user behavior within a session. It records every button click (Event) before a ride is booked.
* **Key Metrics:** Event Type (e.g., 'home page', 'confirm pick-up', 'search failure').
* **Primary/Foreign Keys:** `Event_ID` (PK), `Session_ID` (FK).

#### 4. `Users`

* **Purpose:** Provides demographic context for the riders.
* **Key Metrics:** User Age, Gender, and Phone Number.
* **Primary/Foreign Keys:** `User_ID` (PK), `City_ID` (FK).

#### 5. `Drivers`

* **Purpose:** Contains attributes of the supply side (the driver partners).
* **Key Metrics:** Total Trips Completed (Historical) and Joining Date.
* **Primary/Foreign Keys:** `Driver_ID` (PK), `Vehicle_ID` (FK), `City_ID` (FK).

#### 6. `Cities`

* **Purpose:** Provides geographical context for the entire marketplace.
* **Key Metrics:** City Name (e.g., Bengaluru, Mumbai, Delhi-NCR) and Region.
* **Primary/Foreign Keys:** `City_ID` (PK).

#### 7. `Vehicles`

* **Purpose:** Defines the "Product Tiers" available on the platform.
* **Key Metrics:** Vehicle Type (Uber Go, Uber Auto, Uber Green, Premier, XL) and Fuel Type.
* **Primary/Foreign Keys:** `Vehicle_ID` (PK).

---

### **Data Integrity & Relationship Logic**

* **Transactional Link:** The `rides_raw` table is linked to `app_sessions` via `Session_ID`. This allows us to track which app sessions successfully converted into rides.
* **Supply Link:** `rides_raw` connects to `drivers_dim`, which further connects to `vehicles_dim`. This chain is essential for calculating **Tier-based Profitability (RPK)**.
* **Demographic Link:** Users are connected to their ride requests through the `User_ID` found in the `app_sessions` table, enabling **Age and Gender-based behavioral analysis**.

---

### **What I can do for you next:**

Since your ERD and Data Structure are now documented, would you like me to help you draft the **"3. Executive Summary"**? This section will summarize the "High-Level Wins" of the project for a recruiter who might not have time to read the full technical deep dive.

### Prerequisites

List any software or packages needed to run the project.
```bash
npm install npm@latest -g
