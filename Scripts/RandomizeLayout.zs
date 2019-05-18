Class Room play
{
	int Id;
	Array<int> DoorLines;
	
	bool Constraint(LayoutRandomizer lr, int rooms_explored, int target_room_count, int path_len, int door_count, string pool)
	{
		float completion_pct = float(rooms_explored) / target_room_count;
		if(pool == "BOSS") {
			return path_len >= target_room_count / 5.0;
		}
		else if(pool == "ITEM") {
			return path_len >= target_room_count / 10.0;
		}
		if(door_count >= 3) {
			return completion_pct < .22;
		}
		else if(door_count >= 2) {
			return completion_pct < .45;
		}
		return true;
	}
	
	// If this room is a candidate for placement, should we consider it?
	bool SatisfiesConstraints(LayoutRandomizer lr, int rooms_explored, int target_room_count, int path_len)
	{
		for(int i = 0; i < DoorLines.Size(); ++i)
		{
			string pool = lr.GetPortalPool(DoorLines[i]);
			if(!Constraint(lr, rooms_explored, target_room_count, path_len, DoorLines.Size(), pool)) return false;
		}
		return true;
	}
}

Class IdRoomPair
{
	int Id;
	Room R;
}

// Specialized Id->Room map
Class RoomDict
{
	Array<IdRoomPair> Pairs;
	
	bool HasKey(int id)
	{
		for(int i = 0; i < Pairs.Size(); ++i)
		{
			if(Pairs[i].Id == id) return true;
		}
		return false;
	}
	
	bool Add(Room r)
	{
		if(!HasKey(r.Id)) {
			IdRoomPair pair = new("IdRoomPair");
			pair.Id = r.Id;
			pair.R = r;
			Pairs.Push(pair);
			return true;
		}
		return false;
	}
	
	bool Remove(int id)
	{
		for(int i = 0; i < Pairs.Size(); ++i)
		{
			if(Pairs[i].Id == id) {
				Pairs.Delete(i);
				return true;
			}
		}
		return true;
	}
	
	Room Get(int id)
	{
		for(int i = 0; i < Pairs.Size(); ++i)
		{
			if(Pairs[i].Id == id) {
				return Pairs[i].R;
			}
		}
		return null;
	}
	
	uint Size() { return Pairs.Size(); }
}

Class GraphVertex
{
	int V;
}

Class GraphEdge
{
	int Va;
	int Vb;
}

Class GraphPathNode
{
	int Vcur;
	int Len;
}
	
Class UndirectedGraph
{
	private Array<GraphVertex> Vertices;
	private Array<GraphEdge> Edges;
	
	private GraphEdge _MakeEdge(int v1, int v2)
	{
		GraphEdge edge = new("GraphEdge");
		edge.Va = min(v1, v2);
		edge.Vb = max(v1, v2);
		return edge;
	}
	
	bool AddVertex(GraphVertex vert)
	{
		for(int i = 0; i < Vertices.Size(); ++i)
		{
			if(vert.V == Vertices[i].V) return false;
		}
		
		Vertices.Push(vert);
		return true;
	}
	
	bool AddVertexSimple(int v)
	{
		GraphVertex vert = new("GraphVertex");
		vert.V = v;
		return AddVertex(vert);
	}
	
	bool RemoveVertex(GraphVertex v)
	{
		int idx = Vertices.Find(v);
		if(idx < Vertices.Size())
		{
			Vertices.Delete(idx);
			return true;
		}
		return false;
	}
	
	GraphEdge FindEdge(int v1, int v2)
	{
		let _ = _MakeEdge(v1, v2);
		v1 = _.Va; v2 = _.Vb;
		for(int i = 0; i < Edges.Size(); ++i)
		{
			if(Edges[i].Va == v1 && Edges[i].Vb == v2) return Edges[i];
		}
		return null;
	}
	
	bool Link(int v1, int v2)
	{
		if(FindEdge(v1, v2) != null)
		{
			return false; // Already linked
		}
		GraphEdge edge = _MakeEdge(v1, v2);
		Edges.Push(edge);
		return true;
	}
	
	// Returns the number of edges between v1 and v2.
	int PathLength(int v1, int v2)
	{
		// _MakeEdge sorts v1 and v2 implicitly
		let _ = _MakeEdge(v1, v2);
		v1 = _.Va; v2 = _.Vb;
		
		// Another recursive backtracker yeet
		Array<GraphPathNode> stack;
		Array<int> visited;
		for(int i = 0; i < Edges.Size(); ++i)
		{
			GraphPathNode node = new("GraphPathNode");
			node.Len = 0;
			if(Edges[i].Va == v1 || Edges[i].Vb == v1) {
				node.Vcur = v1;
				stack.Push(node);
			}
		}
		
		while(stack.Size() > 0)
		{
			GraphPathNode node = stack[stack.Size() - 1];
			stack.Pop();
			
			for(int i = 0; i < Edges.Size(); ++i)
			{
				GraphPathNode next_node = new("GraphPathNode");
				next_node.Len = node.Len + 1;
				if(Edges[i].Va == node.Vcur && visited.Find(Edges[i].Vb) == visited.Size()) {
					next_node.Vcur = Edges[i].Vb;
					stack.Push(next_node);
				}
				else if(Edges[i].Vb == node.Vcur && visited.Find(Edges[i].Va) == visited.Size()) {
					next_node.Vcur = Edges[i].Va;
					stack.Push(next_node);
				}
				
				if(next_node.Vcur == v2) return next_node.Len;
				visited.Push(next_node.Vcur);
			}
		}
		return 0;
	}
}

/// Randomizes the layout of specially-crafted maps.
/// In the context of this mod, these are the chambers from Enter the Gungeon.
Class LayoutRandomizer : LevelCompatibility
{
	protected void apply(name checksum, string mapName)
    {
		Randomize(20);
    }
	
	bool IsLineCustomPortal(int l_index) {
		return GetPortalPool(l_index) != "";
	}
	
	int GetRoomId(int s_index) {
		return level.GetUDMFInt(LevelLocals.UDMF_Sector, s_index, "user_roomid");
	}
	
	string GetPortalPool(int l_index) {
		return level.GetUDMFString(LevelLocals.UDMF_Line, l_index, "user_pool");
	}
	
	uint, uint CreateCustomPortal(int line_a, int line_b, out uint unique_tid)
	{
		uint tid1 = unique_tid++;
		uint tid2 = unique_tid++;
		AddLineId(line_a, tid1);
		AddLineId(line_b, tid2);
		SetLineSpecial(line_a, Line_SetPortal, tid2, 0, 2, 0, 0);
		SetLineSpecial(line_b, Line_SetPortal, tid1, 0, 2, 0, 0);
		return tid1, tid2;
	}
	void Randomize(int target_room_count = 15) 
	{
		int error_count = 0;
		uint unique_tid = 1000; // used for portal assignment
		RoomDict rooms = new("RoomDict"); // Map of all room ids to their rooms
		UndirectedGraph paths = new("UndirectedGraph"); // Used to calculate the length of the current path
		Array<int> available; // List of available room ids for connection
		// Iterate all lines and find those marked as portals
		for(int l_idx = 0; l_idx < level.Lines.Size(); l_idx++)
		{
			if(!IsLineCustomPortal(l_idx)) continue;
			// Get the associated room's ID from an adjacent sector
			int roomId = GetRoomId(level.Lines[l_idx].FrontSector.Index());
			// Which must be valid, duh
			if(roomId < 0) {
				console.printf("LayoutRandomizer> INFO: Map has a room with a negative id!");
				return;
			}
			// If it's the first time we see this room, store it
			if(!rooms.HasKey(roomId)) {
				console.printf("LayoutRandomizer> INFO: Found room with id " .. roomId .. ".");
				Room r = new("Room");
				r.Id = roomId;
				rooms.Add(r);
				available.Push(r.Id);
				paths.AddVertexSimple(r.Id);
			}
			// And push this line to the list of available lines for this room
			rooms.Get(roomId).DoorLines.Push(l_idx);
		}
		
		// No rooms? Not a randomizable map.
		if(!rooms.Size()) 
		{
			console.printf("LayoutRandomizer> INFO: Map has no randomizable rooms.");
			return; 
		}
		// Rooms were defined, yet there is no starting room? How confusing.
		if(available.Find(1) == available.Size()) {
			console.printf("LayoutRandomizer> FATAL: Map does not specify a starting room.");
			return;
		}
		
		// The algorithm is a recursive backtracker.
		// Starting from the first room, try to connect each door by satisfying
		// the following constraints:
		// 1. Map size (in rooms) must be very close to the given number
		// 2. The number of connections should be higher for earlier rooms and lower for farther rooms
		// 3. A door with UDMF property "Pool" set to X must be connected to another door with Pool set to X
		// 4. There must be at least one boss room
		// When the current room no longer has pairable doors, pop it from the stack and examine the previous room.
		// Repeat as long as the stack has rooms in it.
		
		Array<int> stack; // Rooms that we're working on
		// Push the starting room onto the stack & remove it from the available rooms
		available.Delete(available.Find(1));
		stack.Push(1);
		
		// Shuffle the list of available rooms: this is where the actual randomization happens
        int i = available.Size();
        while (i-- > 0) {
            let j = random[RL_Random](0, i), k = available[i];
            available[i] = available[j];
            available[j] = k;
		}
		
		// Then sort it by number of connections, ascending. Why sort a list after shuffling it?
		// Because I'm only interested in shuffling the order of rooms with the SAME number of connections.
		// Thus, sorting preserves this randomization while optimizing the algorithm for the first constraint.
		// Btw, this is just a lazy insertion sort.
		i = 1;
        while (i < available.Size()) {
			int j = i;
			while(j > 0 && rooms.Get(available[j - 1]).DoorLines.Size() > rooms.Get(available[j]).DoorLines.Size())
			{
				int temp = available[j - 1];
				available[j - 1] = available[j];
				available[j] = temp;
				j--;
			}
			i++;
		}
		
		console.printf(
			"LayoutRandomizer> INFO: Beginning randomization of " .. rooms.Size() 
			.. " rooms (Target: " .. target_room_count .. " rooms)."
		);
		int rooms_done = 0;
		// As long as there's rooms to connect
		while(stack.Size() > 0)
		{
			int rid = stack[stack.Size() - 1]; stack.Pop();
			int path_len = paths.PathLength(1, rid);
			Room current_room = rooms.Get(rid);
			console.printf("LayoutRandomizer> INFO: Connecting room #" .. rid .. " (Distance: " .. path_len .. ").");
			for(int i = current_room.DoorLines.Size() - 1; i >= 0; --i) {
				Line cur_line = level.Lines[current_room.DoorLines[i]];
				string pool = GetPortalPool(current_room.DoorLines[i]);
				// Find a suitable room to connect to this door
				Room found = null;
				int found_idx = -1;
				for(int j = available.Size() - 1; found_idx == -1 && j >= 0; --j) {
					let av = rooms.Get(available[j]);
					// Ignore rooms that don't match our constraints
					if(!av.SatisfiesConstraints(self, rooms_done, target_room_count, path_len)) {
						continue;
					}
					for(int k = av.DoorLines.Size() - 1; k >= 0; --k)
					{
						Line avl_line = level.Lines[av.DoorLines[k]];
						string avl_pool = GetPortalPool(av.DoorLines[k]);
					
						// Perform the connection
						if(avl_pool == pool) {
							found = av;
							found_idx = j;
							
							uint tid1, tid2;
							[tid1, tid2] = CreateCustomPortal(current_room.DoorLines[i], av.DoorLines[k], unique_tid);
							
							paths.AddVertexSimple(av.Id);
							paths.Link(current_room.Id, av.Id);
							
							current_room.DoorLines.Delete(i);
							av.DoorLines.Delete(k);
							console.printf(
								"LayoutRandomizer> INFO: Connected door with tid " 
								.. tid1
								.. " from room #" .. current_room.Id
								.. " to door with tid " .. tid2
								.. " from room #" .. av.Id
								.. " (pool: " .. pool .. ").");
							break;
						}
					}
				}
				
				// If this fails, there aren't enough rooms defined in the map.
				// We're going to backtrack, but the map is going to have some unconnected portals.
				// To fix either add more prefabs or include a default portal destination.
				if(found_idx < 0) {
					console.printf("LayoutRandomizer> ERROR: No rooms left to connect to this door!");
					error_count++;
					continue;
				}
				
				// Push the room to the stack
				console.printf("LayoutRandomizer> INFO: Pushing room #" .. found.Id .. " to the stack.");
				stack.Push(found.Id);
				available.Delete(found_idx);
				rooms_done++;
			}
		}
		console.printf("LayoutRandomizer> INFO: Done! Rooms placed: %d/%d out of %d rooms.", rooms.Size() - available.Size(), target_room_count, rooms.Size());
		console.printf("LayoutRandomizer> INFO: There are %d errors.", error_count);
	}
}