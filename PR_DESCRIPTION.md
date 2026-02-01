# VannKraft Library Restructuring PR

## Overview
This PR implements a major restructuring of the VannKraft library to organize components into a hierarchical module structure based on the system architecture: Hydraulics, Electrical, Control System, and I/O API.

## Changes Made

### 1. Library Architecture
The library has been reorganized into four main submodules:

#### **Hydraulics Module** (`src/hydraulics/`)
Contains all hydraulic/streamline components for water flow modeling:
- `connectors.jl` - HydroPort connector and FluidData
- `pipe.jl` - Pipe component with friction losses
- `reservoir.jl` - Reservoir pressure boundary
- `surgetank.jl` - Surge tank component
- `turbine.jl` - Turbine with gate control

**Key Features:**
- Darcy friction factor calculation (laminar, transitional, turbulent)
- Pressure and flow dynamics
- Reynolds number based friction modeling

#### **Electrical Module** (`src/electrical/`)
Contains electrical generation components:
- `generators.jl` - SwingGenerator component with swing equation dynamics

**Key Features:**
- Mechanical-to-electrical power conversion
- Generator damping and inertia
- Frequency output signal

#### **Control System Module** (`src/control_system/`)
Contains control and governor components:
- `governor.jl` - Hydro turbine governor with actuator dynamics
- `statistics.jl` - Monitoring utilities (placeholder for AGC/LFC analysis)

**Key Features:**
- PI control loop for frequency regulation
- Gate position ramp-rate limiting
- Droop and deadband control

#### **IOAPI Module** (`src/io_api/`)
Complete I/O, control coordination, and system monitoring (NEW):
- AGC (Automatic Generation Control) with PI control
- LFC (Load Frequency Control) with Area Control Error (ACE)
- Setpoint manager with validation
- Turbine control interface with ramp-rate limiting
- System state monitoring and statistics
- Transient detection

**Key Components:**
```julia
# Data Structures
AGCConfig, LFCConfig, TurbineControlSetpoint, SystemState, ControllerAction

# Managers
SetpointManager - validates and clamps setpoints

# Controllers
AGCController - frequency support with PI control
LFCController - area control with ACE calculation
TurbineControlInterface - gate position management

# Monitoring
compute_frequency_statistics()
compute_power_statistics()
detect_transients()
```

### 2. Module Organization

```
VannKraft/
├── src/
│   ├── VannKraft.jl (main module - updated)
│   ├── hydraulics/
│   │   ├── Hydraulics.jl (submodule aggregator)
│   │   ├── connectors.jl
│   │   ├── pipe.jl
│   │   ├── reservoir.jl
│   │   ├── surgetank.jl
│   │   └── turbine.jl
│   ├── electrical/
│   │   ├── Electrical.jl (submodule aggregator)
│   │   └── generators.jl
│   ├── control_system/
│   │   ├── ControlSystem.jl (submodule aggregator)
│   │   ├── governor.jl
│   │   └── statistics.jl
│   └── io_api/
│       ├── IOAPI.jl (new comprehensive module)
│       └── (submodule aggregator)
└── test/
    ├── runtests.jl (updated with comprehensive tests)
    ├── components_test.jl
    └── trollheim_test.jl
```

### 3. Updated Main Module
The main `VannKraft.jl` now:
- Imports all submodules (Hydraulics, Electrical, ControlSystem, IOAPI)
- Re-exports all public API symbols
- Maintains backward compatibility
- Provides organized access to all functionality

### 4. Comprehensive Test Suite
New comprehensive test suite in `test/runtests.jl` includes:

**Module Loading Tests:**
- ✅ All submodules load successfully
- ✅ Proper module hierarchy

**Hydraulics Tests:**
- ✅ Darcy factor calculations (laminar, turbulent, transitional)
- ✅ Component instantiation
- ✅ Exported symbols

**IOAPI Tests (50+ test cases):**
- ✅ SetpointManager validation and clamping
- ✅ AGCConfig and AGCController
- ✅ LFCConfig and LFCController
- ✅ TurbineControlInterface with history
- ✅ System state and statistics
- ✅ Transient detection
- ✅ Control flow integration

**Integration Tests:**
- ✅ Cross-module component access
- ✅ Control scenario simulation

## API Usage Examples

### AGC Control
```julia
using VannKraft.IOAPI

config = AGCConfig(true, 1.0, 0.5, 0.05, 0.1, 0.01)
controller = AGCController(config)
action = compute_agc_signal(controller, frequency, power, setpoint, time)
```

### Setpoint Management
```julia
manager = SetpointManager(power_setpoint=0.6)
new_power = update_power_setpoint!(manager, 0.7)
new_freq = update_frequency_setpoint!(manager, 51.5)
```

### Turbine Control
```julia
interface = TurbineControlInterface()
setpoint = set_gate_position!(interface, 0.75, 0.1, time)
history = get_control_history(interface, time_window=10.0)
```

### System Monitoring
```julia
states = [SystemState(...), ...]
freq_stats = compute_frequency_statistics(states)
power_stats = compute_power_statistics(states)
transients = detect_transients(states, threshold=0.05)
```

## Backward Compatibility
- ✅ All original exports maintained
- ✅ Can still access `VannKraft.Pipe`, `VannKraft.Turbine`, etc.
- ✅ New functionality available through `VannKraft.IOAPI`

## Testing
Run tests with:
```julia
julia --project=. -e "using Pkg; Pkg.test()"
```

Or run validation script:
```julia
julia --project=. test_validation.jl
```

## Dependencies
- ModelingToolkit
- ModelingToolkitStandardLibrary
- DynamicQuantities
- OrdinaryDiffEq
- Plots
- SciCompDSL

## Future Enhancements
- JSON/CSV I/O for data persistence
- Extended LFC/AGC coordination
- Advanced control strategies (MPC, adaptive control)
- Real-time simulation optimization

## Files Modified
- `src/VannKraft.jl` - Updated to use submodules
- `Project.toml` - Updated dependencies
- `test/runtests.jl` - Comprehensive new test suite

## Files Created
- `src/hydraulics/Hydraulics.jl`
- `src/electrical/Electrical.jl`
- `src/control_system/ControlSystem.jl`
- `src/io_api/IOAPI.jl`
- All submodule files in respective directories
- `test_validation.jl` - Quick validation script
