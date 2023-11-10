shader_type canvas_item;

uniform vec2 direction = vec2(0.0,0.0);
//uniform float speed = 3.0;

void vertex()
{
//	if (direction.x < 0.0  && direction.y < 0.0) {
//		COLOR = vec4(0.0, 0.0, 1.0, 1.0);
//		if (VERTEX.x <= 0.5 && VERTEX.y <= 0.5) {
//			VERTEX += direction;
//		}
//		else if (VERTEX.x >= 0.5 && VERTEX.y >= 0.5) {
//			VERTEX += -direction;
//		}
//	}
//	else if (direction.x < 0.0  && direction.y > 0.0) {
//		COLOR = vec4(1.0, 0.0, 0.0, 1.0);
//		if (VERTEX.x <= 0.5 && VERTEX.y <= 0.5) {
//			VERTEX += direction;
//		}
//		else if (VERTEX.x >= 0.5 && VERTEX.y >= 0.5) {
//			VERTEX += -direction;
//		}
//	}
//	else if (direction.x > 0.0  && direction.y < 0.0) {
//		COLOR = vec4(0.0, 1.0, 0.0, 1.0);
//		if (VERTEX.x <= 0.5 && VERTEX.y <= 0.5) {
//			VERTEX += direction;
//		}
//		else if (VERTEX.x >= 0.5 && VERTEX.y >= 0.5) {
//			VERTEX += -direction;
//		}
//	}
//	else if (direction.x > 0.0  && direction.y > 0.0) {
//		COLOR = vec4(1.0, 1.0, 1.0, 0.5);
//		if (VERTEX.x <= 0.5 && VERTEX.y <= 0.5) {
//			VERTEX += direction;
//		}
//		else if (VERTEX.x >= 0.5 && VERTEX.y >= 0.5) {
//			VERTEX += -direction;
//		}
//	}
	float directionAdditive = direction.y + direction.x;
	if (VERTEX.y < 0.5) VERTEX.y -= abs(directionAdditive);
	else VERTEX.y += abs(directionAdditive);
}