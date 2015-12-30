package org.papervision3d.core.math.util;

class GLU
{
	public static function makeIdentity(m:Array):Void {
		m[0+4*0]=1;m[0+4*1]=0;m[0+4*2]=0;m[0+4*3]=0;
		m[1+4*0]=0;m[1+4*1]=1;m[1+4*2]=0;m[1+4*3]=0;
		m[2+4*0]=0;m[2+4*1]=0;m[2+4*2]=1;m[2+4*3]=0;
		m[3+4*0]=0;m[3+4*1]=0;m[3+4*2]=0;m[3+4*3]=1;
	}
	
	public static function multMatrices(a:Array, b:Array, r:Array):Void {
		var i:Int, j:Int;
		for(i=0;i<4;i++){
			for(j=0;j<4;j++){
				r[int(i*4+j)]=
				a[int(i*4+0)]*b[int(0*4+j)] +
				a[int(i*4+1)]*b[int(1*4+j)] +
				a[int(i*4+2)]*b[int(2*4+j)] +
				a[int(i*4+3)]*b[int(3*4+j)];
			}
		}
	}
	
	public static function multMatrixVec(matrix:Array, a:Array, out:Array):Void {
		var i:Int;
		for(i=0;i<4;i++){
			out[i]=
				a[0] * matrix[int(0*4+i)] +
				a[1] * matrix[int(1*4+i)] +
				a[2] * matrix[int(2*4+i)] +
				a[3] * matrix[int(3*4+i)];
		}
	}
	
	public static function invertMatrix(src:Array, inverse:Array):Bool {
		var i:Int, j:Int, k:Int, swap:Int;
		var t:Float;
	   	var temp:Array<Dynamic>=new Array(4);

		for(i=0;i<4;i++){
			temp[i]=new Array(4);
			for(j=0;j<4;j++){
				temp[i][j]=src[i*4+j];
			}
		}
		makeIdentity(inverse);
	
		for(i=0;i<4;i++){
			/*
			** Look for largest element in column
			*/
			swap=i;
			for(j=i + 1;j<4;j++){
				if(Math.abs(temp[j][i])>Math.abs(temp[i][i])){
					swap=j;
				}
			}
		
			if(swap !=i){
				/*
				** Swap rows.
				*/
				for(k=0;k<4;k++){
					t=temp[i][k];
					temp[i][k]=temp[swap][k];
					temp[swap][k]=t;
			
					t=inverse[i*4+k];
					inverse[i*4+k]=inverse[swap*4+k];
					inverse[swap*4+k]=t;
				}
			}
		
			if(temp[i][i]==0){
				/*
				** No non-zero pivot.  The matrix is singular, which shouldn't
				** happen.  This means the user gave us a bad matrix.
				*/
				return false;
			}
		
			t=temp[i][i];
			for(k=0;k<4;k++){
				temp[i][k] /=t;
				inverse[i*4+k] /=t;
			}
			for(j=0;j<4;j++){
				if(j !=i){
					t=temp[j][i];
					for(k=0;k<4;k++){
						temp[j][k] -=temp[i][k]*t;
						inverse[j*4+k] -=inverse[i*4+k]*t;
					}
				}
			}
		}
		return true;			
	}
	
	public static function ortho(m:Array, left:Float, right:Float, top:Float, bottom:Float, zNear:Float, zFar:Float):Bool {
		var tx:Float=(right + left)/(right - left);
		var ty:Float=(top + bottom)/(top - bottom);
		var tz:Float=(zFar+zNear)/(zFar-zNear);
		
		makeIdentity(m);
		
		m[0]=2 /(right - left);
		m[5]=2 /(top - bottom);
		m[10]=-2 /(zFar-zNear);
		m[12]=tx;
		m[13]=ty;
		m[14]=tz;

		return true;
	}
	
	public static function perspective(m:Array, fovy:Float, aspect:Float, zNear:Float, zFar:Float):Bool {
		var sine:Float, cotangent:Float, deltaZ:Float;
		var radians:Float=(fovy / 2)*(Math.PI / 180);
		
		deltaZ=zFar - zNear;
		sine=Math.sin(radians);
		if((deltaZ==0)||(sine==0)||(aspect==0)){
			return false;
		}
		cotangent=Math.cos(radians)/ sine;
	
		makeIdentity(m);
		
		m[0]=cotangent / aspect;
		m[5]=cotangent;
		m[10]=-(zFar + zNear)/ deltaZ;
		m[11]=-1;
		m[14]=-(2 * zNear * zFar)/ deltaZ;
		m[15]=0;
		
		return true;
	}
	
	public static function scale(m:Array, sx:Float, sy:Float, sz:Float):Void
	{
		makeIdentity(m);
		m[0]=sx;
		m[5]=sy;
		m[10]=sz;
	}
	
	public static function unProject(winx:Float, winy:Float, winz:Float, 
										modelMatrix:Array, projMatrix:Array, 
										viewport:Array, out:Array):Bool {
											
		var finalMatrix:Array<Dynamic>=new Array(16);
		var ein:Array<Dynamic>=new Array(4);

		multMatrices(modelMatrix, projMatrix, finalMatrix);
		
		if(!invertMatrix(finalMatrix, finalMatrix)){
			return false;
		}

		ein[0]=winx;
		ein[1]=winy;
		ein[2]=winz;
		ein[3]=1.0;
		
		// Map x and y from window coordinates
		ein[0]=(ein[0] - viewport[0])/ viewport[2];
		ein[1]=(ein[1] - viewport[1])/ viewport[3];
		
		// Map to range -1 to 1
		ein[0]=ein[0] * 2 - 1;
		ein[1]=ein[1] * 2 - 1;
		ein[2]=ein[2] * 2 - 1;
		
		multMatrixVec(finalMatrix, ein, out);
		
		if(out[3]==0.0)return false;
		out[0] /=out[3];
		out[1] /=out[3];
		out[2] /=out[3];
		
		return true;
	}
}