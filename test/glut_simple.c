#include <OpenGL/gl.h>		// Header File For The OpenGL32 Library
#include <OpenGL/glu.h>		// Header File For The GLu32 Library
#include <GLUT/glut.h>		// Header File For The GLut Library		

#define kWindowWidth	400
#define kWindowHeight	300		

GLvoid InitGL(GLvoid);
GLvoid DrawGLScene(GLvoid);
GLvoid ReSizeGLScene(int Width, int Height);		

int main(int argc, char** argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize (kWindowWidth, kWindowHeight);
	glutInitWindowPosition (100, 100);
	glutCreateWindow (argv[0]);

	InitGL();

	glutDisplayFunc(DrawGLScene);
	glutReshapeFunc(ReSizeGLScene);

	glutMainLoop();

	return 0;
}
