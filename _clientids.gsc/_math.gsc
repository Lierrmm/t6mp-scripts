GetDistance(you, them)
{
	dx = you.origin[0] - them.origin[0];
	dy = you.origin[1] - them.origin[1];
	dz = you.origin[2] - them.origin[2];	
	return floor(Sqrt((dx * dx) + (dy * dy) + (dz * dz)) * 0.03048);
}

vector_scale(vec, scale)
{
   return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}