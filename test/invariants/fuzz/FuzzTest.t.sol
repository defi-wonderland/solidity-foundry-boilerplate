// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {GreeterGuidedHandlers} from './handlers/guided/Greeter.t.sol';
import {GreeterUnguidedHandlers} from './handlers/unguided/Greeter.t.sol';
import {GreeterProperties} from './properties/Greeter.t.sol';

contract FuzzTest is GreeterGuidedHandlers, GreeterUnguidedHandlers, GreeterProperties {}
