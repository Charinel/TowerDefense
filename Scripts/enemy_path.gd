extends Node

# Define a class to represent each node in the graph
class EnemyPath:
	var name: String
	var neighbors: Dictionary  #S Dictionary of neighbors with their weights
	var distance: float
	var previous: EnemyPath

	func _init(name: String):
		self.name = name
		self.neighbors = {}
		self.distance = INF
		self.previous = null

# Infinite distance value
const INF = 1e100

func dijkstra(start: EnemyPath, target: EnemyPath, graph: Dictionary) -> Array:
	var unvisited_nodes = []
	var path = []
	
	# Initialize distances
	for node in graph.keys():
		node.distance = INF
		node.previous = null
		unvisited_nodes.append(node)
		
	start.distance = 0
	
	while unvisited_nodes.size() > 0:
		# Get the node with the smallest distance
		var current_node = get_min_distance_node(unvisited_nodes)
		unvisited_nodes.erase(current_node)
		
		# If the smallest distance is infinity, we are done
		if current_node.distance == INF:
			break
		
		# Update distances for neighbors
		for neighbor in current_node.neighbors.keys():
			var alt = current_node.distance + current_node.neighbors[neighbor]
			if alt < neighbor.distance:
				neighbor.distance = alt
				neighbor.previous = current_node
	
	# Reconstruct the path from target to start
	var step = target
	while step:
		path.insert(0, step.name)
		step = step.previous
	
	return path

func get_min_distance_node(nodes: Array) -> EnemyPath:
	var min_node = null
	var min_distance = INF
	
	for node in nodes:
		if node.distance < min_distance:
			min_node = node
			min_distance = node.distance
	
	return min_node

# Example Usage
func _ready():
	var graph = {}
	
	# Create nodes
	var A = EnemyPath.new("A")
	var B = EnemyPath.new("B")
	var C = EnemyPath.new("C")
	var D = EnemyPath.new("D")
	
	# Define neighbors and weights
	A.neighbors[B] = 1
	A.neighbors[C] = 4
	B.neighbors[C] = 2
	B.neighbors[D] = 5
	C.neighbors[D] = 1
	
	graph[A] = A
	graph[B] = B
	graph[C] = C
	graph[D] = D
	
	var path = dijkstra(A, D, graph)
	print("Shortest path from A to D: ", path)
