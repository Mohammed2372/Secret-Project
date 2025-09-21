# AI Maze Game - Algorithm Implementation Guide

This project implements a maze-solving game with progressively complex AI algorithms across different levels. Each level introduces a more sophisticated pathfinding strategy, making the AI more challenging to compete against.

## Level 1: Farthest-First Breadth-First Search (Easy Mode)

The first level implements a modified Breadth-First Search (BFS) algorithm that prioritizes collecting the farthest coins first. This creates a predictable but less efficient AI opponent.

Key features:
- Uses BFS to explore the maze
- Targets the farthest reachable coin/collectible
- Maintains distance tracking for all cells
- Less efficient pathing creates opportunities for players to win

Algorithm complexity: O(N×M) per coin, where N and M are the maze dimensions.

## Level 2: Nearest-First BFS (Medium Mode)

The second level implements a more efficient pathfinding strategy using standard BFS to always target the nearest coin/collectible. This creates a more challenging opponent that makes locally optimal decisions.

Key features:
- Standard BFS implementation
- Targets the nearest reachable coin/collectible
- Stops searching once a target is found
- More efficient than Level 1 but still not globally optimal
- Creates a balanced challenge for intermediate players

Algorithm complexity: O(N×M) per coin, but with early termination when finding the nearest target.

## Level 3: Traveling Salesman Optimization (Hard Mode)

The third level implements a significantly more sophisticated algorithm that solves a variation of the Traveling Salesman Problem (TSP) to find the globally optimal path to collect all coins.

Key features:
- Uses BFS for pathfinding between coins
- Builds a complete distance matrix between all coins
- Implements dynamic programming to solve the TSP
- Finds the globally optimal solution for collecting all coins
- Creates a highly challenging AI opponent

Algorithm implementation details:
1. Coin Location Discovery: Scans the maze to find all coins and starting position
2. Distance Matrix Construction: Calculates shortest paths between all coin pairs
3. TSP Optimization: Uses dynamic programming to find the optimal collection order
4. Path Reconstruction: Generates the complete movement sequence

Algorithm complexity: O(N×M) for pathfinding between coins, O(2^K × K^2) for TSP optimization where K is the number of coins.

## Technical Implementation

The project is implemented in Godot Engine using GDScript. Each level's algorithm is contained in its own script:
- `level_1_algo.gd`: Farthest-First BFS implementation
- `level_2_algo.gd`: Nearest-First BFS implementation
- `level_3_algo.gd`: TSP with BFS pathfinding implementation

The maze is represented as a 2D array where:
- '#' represents walls
- 'C' represents coins
- 'B' represents special collectibles
- 'S' represents the starting position
- '.' represents empty paths

## Performance Considerations

The algorithms are designed with different performance characteristics to create a progression in difficulty:
- Level 1: Intentionally sub-optimal but predictable
- Level 2: Locally optimal but globally sub-optimal
- Level 3: Globally optimal but computationally more intensive

This progression creates an engaging learning curve for players while demonstrating different approaches to pathfinding and optimization problems in game AI.