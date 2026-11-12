# Hydroponics combined dataset

Input: RES406_Spring2026_Datasheet.xlsx. Output: hydroponics_ml.csv (UTF-8, comma separated).

One file preserves several observation grains, identified by record_type. For a harvest modeling dataframe, filter record_type == 'harvest'. Each harvest row represents one crop, wall, side and tube, not an individual plant. Other record types retain lighting, water trials, dissolved oxygen, dated events and slot layouts without inventing matches or multiplying harvest rows.

## Columns and units
- record_id: unique row identifier; experiment_id: experiment grouping key.
- date: ISO calendar date. date_basis distinguishes explicit dates from harvest dates inferred from a crop/wall harvest log. Undated observations remain blank.
- crop, variety: standardized names; variety_raw: original label. Bloom -> Bloomsdale, Top -> Top Bunch, Trop -> Tropicana, Butter -> Green Butter, Argula -> Arugula. Crop is populated on harvest and event records.
- wall_id, side, tube_id: physical tube identity within the experiment. slot_id is used only for layouts; tray_id only for seedling light measurements.
- plant_count: recorded harvested plant count. fruit_count: recorded fruit count, including observed zero counts.
- harvest_weight: recorded tube harvest weight. Leafy weights are consistent with gram-labeled workbook summaries; fruit weight units are not explicitly labeled. Confirm units before comparing crops. harvest_weight_status preserves 'lost data' and distinguishes missing from observed weights.
- leaves_slot_2/4/6: sampled leaf counts. mean_sampled_leaves averages available counts, including actual zeros. weight_per_plant divides tube weight by recorded plant_count; it is a derived outcome, not a predictor for weight.
- seed_date: latest relevant sowing/replanting log; transplant_date: relevant transplant log. days_since_sowing/transplant are elapsed calendar days (sowing day = 0), distinct from the workbook's day-1 DAP convention. These dates are inferred crop-level context, not tracked plant identities.
- light_zone, light_bar, light_value: original light zone and measurement bar. light_zone_mean: mean of seven bar readings for a labeled zone, joined to harvest by wall, side and tube range. light_distance: original distance value. Light and distance units were not provided; no assumed PPFD, lux or distance conversion. Measurements are undated. Shared boundary tubes are left unmatched rather than averaged speculatively. light_join_basis describes this.
- position: seedling tray front/middle/back. Seedling light readings stay separate: individual harvested plants cannot be traced back to trays.
- trial, water_volume_ml, water_duration_min, water_pressure_psi: water-output observations (5-minute trials at 25 psi). water_tube_trial_mean_ml joins only an exactly measured wall/tube to a harvest. Side was not recorded and these observations are undated. Other tubes are not interpolated. Trial number follows column position; the duplicated 'Trial 4' header on wall 3 has no populated values.
- tank, do_static, do_running: dissolved-oxygen readings with explicit dates and tank labels. Units were not provided. 'Grow Wall' does not identify a numbered wall, so these are not attached to individual harvests.
- dap_reported: explicitly recorded DAP on event rows; notes retains original event text, including nutrient/pH/light/watering settings and conflicting wall references. Settings are not assumed to persist through time.
- source_sheet, source_cells: original provenance for measurements; context_sources: sheets used for harvest context. source_cells indicates the source row range or measurement cell, not all joined cells.

## Decisions and limitations
Graphs, duplicated graph input tables, workbook summary calculations and date-only calendar rows are excluded. Sheet1 repeats Collards_Data summaries. Cucumber and bell-pepper sorted/reformatted copies are excluded. Missing weights remain empty, never zero; explicitly measured zeros remain zero. Layout blanks are not assumed to mean empty; explicit Empty and ambiguous labels are preserved.

Leafy wall/side identities follow harvest block headers. Several transplant log notes call walls 1/2 where harvest sheets identify 2/3; those conflicts remain in event notes and were not used to assign watering/light schedules. Harvest dates are inferred from log events and need confirmation if multiple harvest rounds occurred. Static lighting snapshots are spatial context, not a measured exposure history.

For machine learning, exclude record_id, provenance, harvest-derived quantities and post-harvest event text from predictors as appropriate for your target. Split by experimental groups/walls rather than randomly treating neighboring tubes as independent experiments. This is a small, observational experiment with crop/wall confounding.

## Adding weather and nutrients
Use experiment_id plus ISO date for daily lab-wide observations; include wall_id or tank identity where measurements are specific. For harvest modeling, summarize weather/nutrient exposure between seed_date or transplant_date and harvest date before joining, rather than joining raw time-series rows directly (which duplicates harvests). Keep timestamps and time zones in future raw data. Dates alone do not imply an outdoor-weather measurement equals the indoor environment.

## Reproduce
Run ./inspect.ps1 and then ./build_dataset.ps1 in PowerShell from this directory. inspect.ps1 reads workbook XML directly; no Excel installation or third-party packages are needed. The original workbook is unchanged.

Example pandas load:

```python
import pandas as pd
all_data = pd.read_csv('hydroponics_ml.csv')
harvest = all_data.loc[all_data.record_type.eq('harvest')].copy()
```

Validation: 2,925 rows total; 324 unique harvest crop/wall/side/tube records; 311 harvests joined to lighting zones. All 324 harvest dates could be inferred from crop logs. One light-zone header ('Lightwall 2_2') was normalized to 2b_2 using its location in the 2B block. Thirteen boundary tubes have no light-zone assignment. The exported CSV was re-imported to confirm row count; harvest keys were checked for duplicates.
