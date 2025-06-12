#!/usr/bin/env python3

import yaml
import sys
from collections import defaultdict

def check_circular_dependencies(recipes):
    """Check for circular dependencies in recipes"""
    
    # Build dependency graph
    graph = defaultdict(list)
    for recipe in recipes:
        name = recipe['name']
        deps = recipe.get('dependencies', [])
        graph[name] = deps
    
    # Check for cycles using DFS
    def has_cycle(node, visited, rec_stack):
        visited[node] = True
        rec_stack[node] = True
        
        for neighbor in graph.get(node, []):
            if neighbor not in visited:
                if has_cycle(neighbor, visited, rec_stack):
                    return True
            elif rec_stack[neighbor]:
                print(f"❌ Circular dependency detected: {node} -> {neighbor}")
                return True
        
        rec_stack[node] = False
        return False
    
    visited = {}
    rec_stack = {}
    
    for node in graph:
        if node not in visited:
            if has_cycle(node, visited, rec_stack):
                return False
    
    return True

def check_dependency_exists(recipes):
    """Check that all dependencies reference existing recipes"""
    recipe_names = {r['name'] for r in recipes}
    
    for recipe in recipes:
        name = recipe['name']
        deps = recipe.get('dependencies', [])
        
        for dep in deps:
            if dep not in recipe_names:
                print(f"❌ Recipe '{name}' depends on non-existent recipe '{dep}'")
                return False
    
    return True

def main():
    try:
        with open('recipes.yaml', 'r') as f:
            data = yaml.safe_load(f)
        
        recipes = data['recipes']
        
        # Check for circular dependencies
        if not check_circular_dependencies(recipes):
            sys.exit(1)
        
        # Check that all dependencies exist
        if not check_dependency_exists(recipes):
            sys.exit(1)
        
        print("✅ All dependency checks passed")
        
    except Exception as e:
        print(f"❌ Error checking dependencies: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()