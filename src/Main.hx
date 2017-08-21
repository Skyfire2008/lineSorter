package ;

import sys.io.File;

import haxe.ds.Vector;

import haxe.io.Output;
import haxe.io.Input;
import haxe.io.Bytes;

import format.png.Reader;
import format.png.Writer;
import format.png.Tools;
import format.png.Data;

using Lambda;

class Main{

	private static var stderr: Output=Sys.stderr();
	private static var stdout: Output=Sys.stdout();

	private static var stdin: Input=Sys.stdin();

	private static var bytesIn: Bytes;
	private static var width: Int;
	private static var height: Int;
	private static var bytesOut: Bytes;

	static function main(){

		//var handler: ArgumentHandler=new ArgumentHandler();

		//read the image
		var reader=new Reader(File.read(Sys.args()[0]));
		var data=reader.read();
		var header=Tools.getHeader(data);
		width=header.width;
		height=header.height;
		bytesIn=Tools.extract32(data);
		bytesOut=Bytes.alloc(bytesIn.length);

		//calculate the brightness of every line
		var colorAccum: Vector<Color>=new Vector<Color>(width);
		var lines: Vector<Cell>=new Vector<Cell>(width);
		for(i in 0...width){
			var currentColor=new Color(0, 0, 0);

			for(j in 0...height){
				var pos=bytesPos(i, j);
				currentColor.b+=bytesIn.get(pos);
				currentColor.g+=bytesIn.get(pos+1);
				currentColor.r+=bytesIn.get(pos+2);
			}

			colorAccum[i]=currentColor;
			lines[i]={bright: 0.2126*currentColor.r + 0.7152*currentColor.g + 0.0722*currentColor.b, pos: i};
		}

		//sort the lines by brightness
		sort(lines, 0, lines.length);

		//generate output image
		for(i in 0...width){
			var lineNum=lines[i].pos;

			for(j in 0...height){
				var inPos=bytesPos(lineNum, j);
				var outPos=bytesPos(i, j);
				bytesOut.set(outPos, bytesIn.get(inPos));
				bytesOut.set(outPos+1, bytesIn.get(inPos+1));
				bytesOut.set(outPos+2, bytesIn.get(inPos+2));
				bytesOut.set(outPos+3, bytesIn.get(inPos+3));

				/*
				try{
					var color=bytesIn.getInt64(bytesPos(lineNum, j));
					bytesOut.setInt64(bytesPos(i, j), color);
				}catch(e: Dynamic){
					trace(e);
				}*/
			}
		}

		var writer=new Writer(File.write(Sys.args()[0]+"-output.png"));
		writer.write(Tools.build32BGRA(width, height, bytesOut));
	}

	static inline function bytesPos(x: Int, y: Int): Int{
		return (y*width+x)<<2;
	}

	static inline function swap<T>(v: Vector<T>, a: Int, b: Int){
		var temp: T=v[a];
		v[a]=v[b];
		v[b]=temp;
	}

	static function sort(array: Vector<Cell>, start: Int, length: Int){
		if(length<=1){
			return;
		}else{
			var hLength=length>>1;
			sort(array, start, hLength);
			sort(array, start+hLength, length-hLength);
			merge(array, start, hLength, length);
		}
	}

	/**
	 * @brief						merges two adjacent blocks of an array
	 * 
	 * @param array					array to merge
	 * @param start					starting position of first block
	 * @param hLength				half length, length of first block, starting position of second block
	 * @param length				total length of blocks
	 */
	static function merge(array: Vector<Cell>, start: Int, hLength: Int, length: Int){
		var i: Int=start;
		var j: Int=start+hLength;
		var tempArr: Vector<Cell>=new Vector<Cell>(length);
		var pos: Int=0;

		while(i<start+hLength && j<start+length){
			if(array[i].bright<array[j].bright){
				tempArr[pos]=array[i];
				i++;
			}else{
				tempArr[pos]=array[j];
				j++;
			}

			pos++;
		}

		//if one of blocks still has untouched elements
		if(i<start+hLength){
			while(i<start+hLength){
				tempArr[pos]=array[i];
				i++;
				pos++;
			}
		}else if(j<start+length){
			while(j<start+length){
				tempArr[pos]=array[j];
				j++;
				pos++;
			}
		}

		Vector.blit(tempArr, 0, array, start, length);
	}
}

class HSL{
	public var h: Float;
	public var s: Float;
	public var l: Float;

	public function new(h: Float, s: Float, l: Float){
		this.h=h;
		this.s=s;
		this.l=l;
	}
}

class Color{
	public var r: Int;
	public var g: Int;
	public var b: Int;

	public function new(r: Int, g: Int, b: Int){
		this.r=r;
		this.g=g;
		this.b=b;
	}

	public function toHSL(): HSL{
		var R: Float=this.r/255.0;
		var G: Float=this.g/255.0;
		var B: Float=this.b/255.0;

		var maxC=Math.max(Math.max(R, G), B);
		var minC=Math.min(Math.min(R, G), B);

		var L: Float=0.5*(minC+maxC); //calculate lightness

		var S: Float=0;
		var H: Float=0;

		if(maxC!=minC){
			if(L<0.5){ //calculate saturation
				S=(maxC-minC)/(maxC+minC);
			}else{
				S=(maxC-minC)/(2-(maxC+minC));
			}

			if(R==maxC){ //calculate hue
				H=(G-B)/(maxC-minC);
			}else if(G==maxC){
				H=2+(B-R)/(maxC-minC);
			}else{
				H=4+(R-G)/(maxC-minC);
			}

			H*=60;
			if(H>360){
				H-=360;
			}else if(H<0){
				H+=360;
			}
		}

		return new HSL(H, S, L);
	}
}

typedef Cell={
	var bright: Float;
	var pos: Int;
}