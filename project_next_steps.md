# Inventory Analysis Project — Next Steps \& Context



## Where the Project Stands

The project is technically solid. Full RAW/CORE/MART pipeline, Snowflake + dbt Core + Power BI, S3 ingestion, 39 automated tests, lineage graph, GitHub repo, documented findings. This is real infrastructure work — most junior analyst candidates haven't touched dbt at all.

The README is well written. The four findings are clearly framed with causes and recommendations attached. The AI disclosure section is smart and honest.



\---

## The Gap — What the Project Is Missing

The project currently answers: **"where is the inventory system broken."**

Operations hiring managers need it to answer: **"what is it costing, and what should we fix first."**

The data to answer that is already ingested. These mart models are not built yet:

### 1\. Gross Margin Per Product

* **Data available:** `unit\_cost` in `dim\_product\_master`, `net\_revenue` in `fct\_daily\_sales`
* **What to build:** Margin per product. Combine with velocity classification from `mart\_product\_velocity` to produce a 2x2: high margin/high velocity, high margin/low velocity, low margin/high velocity, low margin/low velocity
* **Why it matters:** Operations managers prioritise by margin impact, not just volume. This crosses the line from inventory observation to financial consequence

### 2\. Cost of Stockouts (Revenue Lost)

* **Data available:** Stockout days in `mart\_inventory\_health`, average daily units sold and price in `fct\_daily\_sales`
* **What to build:** Estimated lost revenue per product per store = stockout days × average daily units sold × unit price
* **Why it matters:** Turns "this product stockouts 30% of the time" into "this product cost us an estimated $X in lost sales last year" — that's the language operations people respond to

### 3\. Cash Tied Up in Overstock

* **Data available:** Overstock days in `mart\_inventory\_health`, average closing stock and unit cost
* **What to build:** Estimated cash tied up = overstock days × average excess units × unit cost
* **Why it matters:** Companion metric to the stockout cost — together they give a full picture of the financial cost of the broken reorder system

### 4\. Supplier Performance

* **Data available:** `core\_purchase\_orders` already built — order date, expected receipt date, planned lead time, order status
* **What to build:** Actual vs planned lead time per supplier. Supplier reliability score
* **Why it matters:** `core\_purchase\_orders` was built but no mart consumes it — this is unfinished work and a missed opportunity. Supplier reliability is directly relevant to operations roles

### 5\. Discount Impact Analysis

* **Data available:** Discount column in `fct\_daily\_sales`
* **What to build:** Does discounting actually accelerate sell-through on slow movers, or does it just erode margin without moving volume?
* **Why it matters:** Answers a real commercial question about whether the current promotional strategy is working

### 6\. Store-Level Performance

* **Data available:** Store dimension already exists across all fact tables
* **What to build:** Which store is operationally best and worst? Rank stores by stockout rate, overstock rate, turnover, and estimated revenue loss
* **Why it matters:** The current findings collapse to catalogue-wide conclusions. Store-level variance is where the actionable operational insight lives

\---

## How to Reframe the Dashboard

Once the financial mart models are built, the Power BI dashboard needs one additional page or a reframing of the existing findings:

**Current framing:** "Here is where the inventory system is broken"  
**Target framing:** "Here is what it is costing, and here is the priority order for fixing it"

A simple priority matrix — products ranked by combined stockout cost + cash tied up — would make the dashboard immediately actionable for an operations audience.

\---

\---

## Overall Assessment

This project hits the mark technically. The gap is not the infrastructure — it is the translation from operational observation to financial consequence. That is two or three additional mart models and a reframing of the findings.

It is probably a weekend of work, not a new project.

Do it when you have the energy. Not before.

\---

*Context from conversation with Claude, April 2026*

