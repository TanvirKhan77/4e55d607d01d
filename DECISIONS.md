## Ambiguity 1: Device Data Visibility Scope
**Question**: Should the application display all devices' readings or only the authenticated user's devices?

**Options Considered**:
- Option A: Show only the authenticated user's devices
- Option B: Show all devices with role-based access
- Option C: Show all devices with public/private flags

**Decision**: I chose Option A (user-only devices) because:
1. This aligns with typical IoT dashboard patterns where users manage their own devices
2. Simplifies security and data privacy concerns
3. Reduces complexity in data filtering and permission management

**Trade-offs**: 
1. Users cannot view shared or public devices from other users
2. Reduced collaboration potential between users
3. Simpler implementation but less flexible for organizational use cases

---

## Ambiguity 2: Analytics Endpoint Response Format
**Question**: What specific analytics should be returned beyond the rolling average?

**Options Considered**:
- Option A: Only rolling average (minimalist, meets literal requirement)
- Option B: Comprehensive statistics (min, max, average, standard deviation, count, trend direction)
- Option C: Time-windowed analytics (last hour, last day, last week) with comparisons
- Option D: Health status indicators (normal, warning, critical) based on thresholds

**Decision**: I chose Option B (comprehensive statistics) because:
1. Provides immediate actionable insights without additional API calls
2. Enables richer frontend visualizations (charts, gauges, alerts)
3. Follows the principle of providing complete information for a given resource
4. Aligns with industry standards for telemetry analytics endpoints

**Trade-offs**: 
1. Users cannot view shared or public devices from other users
2. Reduced collaboration potential between users
3. Simpler implementation but less flexible for organizational use cases

---

## Ambiguity 3: UI Theme Implementation
**Question**: Should the application support multiple visual themes or maintain a single consistent theme?

**Options Considered**:
- Option A: Single light theme (consistent branding, simpler implementation)
- Option B: System preference detection (light/dark based on OS settings)
- Option C: User-selectable themes (light/dark with persistence)
- Option D: Health status indicators (normal, warning, critical) based on thresholds

**Decision**: I chose Option C (user-selectable light/dark themes) because:I chose Option C (user-selectable light/dark themes) because:
1. Dark themes reduce eye strain in low-light conditions - important for monitoring applications
2. Personal preference significantly impacts user experience and comfort
3. Theme persistence demonstrates attention to user preferences

**Trade-offs**: 
1. Additional development and testing time
2. Potential for theme-specific bugs

---

## Assumptions Made

### Assumption 1: Users Want Actionable Health Metrics
**Assumption**: Users need more than just current vitals; they need trends to understand device health.

**Why it's reasonable**:
- Health monitoring apps (Apple Health, Samsung Health) all show trends
- Single data points lack context
- Users need to understand if their device is degrading
- Historical data enables better decision-making

**Implementation Impact**: Added rolling average, analytics endpoints, and history screen.

---

### Assumption 2: Users Care About Battery Impact
**Assumption**: Battery efficiency is important enough to compromise on exact timing.

**Why it's reasonable**:
- Mobile device battery is finite resource
- Users tolerate ±2 minute variance in logging interval
- Better battery performance = more likely to keep app installed

**Implementation Impact**: Platform-specific scheduling strategies, minimum 5-minute interval floor.

---

### Assumption 3: Real Device Vitals Require Native Channel
**Assumption**: Accurate thermal and memory data requires native code, not Dart approximations.

**Why it's reasonable**:
- Dart can approximate battery level via plugins
- True thermal state requires native APIs (Android ThermalStatusListener)
- Memory usage calculation is OS-specific
- Users expect "real" metrics, not estimates

**Implementation Impact**: MethodChannel integration.

---

## Questions I Would Ask Product Manager

### If this were a real project with available clarification:

#### Question 1: Analytics Retention Window
How long should we keep historical vitals? Daily data for 1 year, or hourly data for 1 week? This affects storage design, API complexity, and performance.

#### Question 2: Alerting Strategy
Should the app alert users when vitals cross thresholds? (e.g., 'Battery below 20%' or 'Device running hot'). This affects feature scope significantly.

#### Question 3: Data Privacy
Should vitals data sync to cloud, stay local-only, or be user-configurable? This affects backend infrastructure, security model, and compliance needs.

#### Question 4: Multi-Device Support
Should one user monitor multiple devices? This changes database schema, API design, and sync complexity.

#### Question 5: Offline Support
When network is unavailable, should the app buffer vitals locally or skip logging? Current implementation skips (fails silently). Buffering requires local database.

#### Question 6: Export/Reporting
Should users be able to export their vital history as CSV/PDF? For health analysis or sharing with support teams? This affects data structure.

#### Question 7: Notification Strategy
Should the app use notifications for important events? Push notifications would require backend infrastructure and permissions changes.