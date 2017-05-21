package ;

import sys.io.File;

import haxe.ds.Vector;

import haxe.io.Output;
import haxe.io.Input;
import haxe.io.Bytes;

import format.png.Reader;
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
	private static var bytesOut: Int;

	static function main(){

		//var handler: ArgumentHandler=new ArgumentHandler();

		//read the image
		var reader=new Reader(File.read(Sys.args()[0]));
		var data=reader.read();
		var header=Tools.getHeader(data);
		width=header.width;
		height=header.height;
		bytesIn=Tools.extract32(data);
		bytesOut=Bytes.alloc(width*height*4);

		//calculate the brightness of every line
		var colorAccum: Vector<Color>=new Vector<Color>(width);
		var lines: Vector<Cell>=new Vector<Cell>(width);
		for(i in 0...width){
			var currentColor={r:0, g:0, b:0};

			for(j in 0...height){
				var pos=i*j>>2;
				currentColor.r+=bytesIn.get(pos);
				currentColor.g+=bytesIn.get(pos+1);
				currentColor.b+=bytesIn.get(pos+2);
			}

			colorAccum[i]=currentColor;
			lines[i]={bright: 0.2126*currentColor.r + 0.7152*currentColor.g + 0.0722*currentColor.b, pos: i};
		}

		//sort the lines by brightness
		sort(lines, 0, lines.length);

		for(i in 0...width){
			var lineNum=lines[i].pos;

			for(j in 0...height){

			}
		}


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

typedef Color={
	var r: Int;
	var g: Int;
	var b: Int;
}

typedef Cell={
	var bright: Float;
	var pos: Int;
}