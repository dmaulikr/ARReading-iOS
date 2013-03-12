#import "GLShaderTest.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// Nice Stuff!!!
#define GLSL(src) #src

static int textureUnitIndex = 0;

@interface GLShaderTest (){
	uint32_t _programId;
	int      _position;
    //	int     _normal;
	int     _texcoord;
	int     _textures[16];  // _textures
}
-(void)loadShaders;
@end

@implementation GLShaderTest

@synthesize position = _position;
//@synthesize normal = _normal;
@synthesize texcoord = _texcoord;
@synthesize modelView = _modelView;

-(void)bind{
	if( _programId==0 ){
		[self loadShaders];
	}
	if( _programId == 0 ){
		return;
	}
	glUseProgram(_programId);
	[self resetTextures];
}

-(void)unbind{
	[self resetTextures];
	glUseProgram(0);
}

-(void)resetTextures{
	for(int i=0;i<textureUnitIndex;i++){
		glActiveTexture(GL_TEXTURE0+i);
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	textureUnitIndex = 0;
}

-(void)setTexture:(uint32_t)textureId forKey:(NSString*)key{
	glUniform1i(glGetUniformLocation(_programId,[key UTF8String]), textureUnitIndex);
	glActiveTexture(GL_TEXTURE0+textureUnitIndex);
	glBindTexture(GL_TEXTURE_2D, textureId);
	textureUnitIndex++;
}

-(void)setTexture:(uint32_t)textureId atIndex:(int)index{
	if( index < 0 || index >= 16 ){ return; }
	glUniform1i(_textures[index], textureUnitIndex);
	glActiveTexture(GL_TEXTURE0+textureUnitIndex);
	glBindTexture(GL_TEXTURE_2D, textureId);
	textureUnitIndex++;
}

-(void)loadShaders{
    // dummy
}

// 加载 vs、fs
-(BOOL)loadShaders:(const char*)vsrc :(const char*)fsrc
{
    // 创建 program
	_programId = glCreateProgram();
	if( _programId == 0 ){
		NSLog(@"Failed to create program");
		return FALSE;
	}
    
    // 分别加载 vs、fs
	if( ![self loadShader:vsrc type:GL_VERTEX_SHADER] ){
		return FALSE;
	}
	if( ![self loadShader:fsrc type:GL_FRAGMENT_SHADER] ){
		return FALSE;
	}
	
	glLinkProgram(_programId);
	
	GLint status;
	glGetProgramiv(_programId, GL_LINK_STATUS, &status);
	if( status == 0 ){
		NSLog(@"Failed to link program");
		return FALSE;
	}
	
	_position = glGetAttribLocation(_programId,"position");
    //	_normal = glGetAttribLocation(_programId,"normal");     // normal?
	_texcoord = glGetAttribLocation(_programId,"texcoord");
    
    _modelView = glGetUniformLocation(_programId, "modelView");
	
    // 支持 16 个 texture
	_textures[0] = glGetUniformLocation(_programId,"_MainTex");
	char texname[16];
	for(int i=1;i<16;i++){
		sprintf(texname,"_SubTex%d",i);
		_textures[i] = glGetUniformLocation(_programId,texname);
	}
	
	return TRUE;
}

// 创建一个 shader
-(BOOL)loadShader:(const char*)src type:(uint32_t)type{
	if( !src ){
		NSLog(@"Failed to load shader");
		return FALSE;
	}
    
    // create
	GLuint shaderId = glCreateShader(type);
	glShaderSource(shaderId, 1, &src, NULL);
	glCompileShader(shaderId);
	
    // log
    GLint loglen;
	glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &loglen);
    if( loglen > 0 ){
		char *log = (char *)malloc(loglen);
		glGetShaderInfoLog(shaderId, loglen, &loglen, log);
		NSLog(@"Shader compile log: [%s]", log);
		free(log);
	}
    
    // status
	GLint status = 0;
    glGetShaderiv(shaderId, GL_COMPILE_STATUS, &status);
    if (status == 0){
        glDeleteShader(shaderId);
		NSLog(@"Failed to compile shader");
        return FALSE;
    }
    
    // attach
	glAttachShader(_programId, shaderId);
	glDeleteShader(shaderId);
	return TRUE;
}

@end

@implementation GLTexShader

// override loadShaders
-(void)loadShaders{
	const char *src[2] = {
		GLSL(
			 attribute vec4 position;
			 attribute vec2 texcoord;
             
             uniform mat4 modelView;
             
			 varying vec2 v_TexCoord;
			 void main(){
				 gl_Position = modelView * position;
				 v_TexCoord = texcoord;
			 }
             ),
        /*
         // Standard Vertex Shader
         attribute vec4 position;
         attribute vec2 texcoord;
         uniform mat4 mvp;
         varying mediump vec2 v_texcoord;
         void main()
         {
         gl_Position = mvp * position;
         v_texcoord=texcoord;
         }
         */
		GLSL(
			 varying lowp vec2 v_TexCoord;
			 uniform sampler2D _MainTex;
			 void main(){
				 gl_FragColor = texture2D(_MainTex,v_TexCoord);
			 }
             )
        /*
         // Standard Fragment Shader
         varying mediump vec2 v_texcoord;
         uniform sampler2D texture;
         void main()
         {
         gl_FragColor = texture2D(texture, v_texcoord);
         }
         */
	};
	[self loadShaders:src[0] :src[1]];
}

@end



