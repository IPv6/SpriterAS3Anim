package com.acemobe.treefortress.spriter
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import com.acemobe.treefortress.starling.AtlasBuilder;
	import com.acemobe.treefortress.utils.URLImageLoader;

	public class SpriterLoader
	{
		public var spriteXml:XML;
		protected var pathsByLoader:Dictionary;
		protected var namesByLoader:Dictionary;
		
		protected var xmlLoaders:Vector.<URLLoader>;
		protected var imageLoaders:Vector.<URLImageLoader>;
		protected var scmlByName:Object;
		
		protected var pieces:Vector.<Bitmap>;
		
		protected var atlasXml:XML;
		protected var atlasBitmap:BitmapData;
		
//		public var animationSets:Vector.<AnimationSet>;
		
		protected var loadQueue:String;
		protected var _textureScale:Number;
		
		public var textureAtlas:TextureAtlas;
		public var xmlList:String;
		public var onLoaded:Function;
		public var onFailed:Function;
		protected var loadStart:int;

		
		public function SpriterLoader(_onLoaded:Function,_onFailed:Function) {
			pathsByLoader = new Dictionary();
			namesByLoader = new Dictionary();
			scmlByName = {};
			xmlLoaders = new <URLLoader>[];
			imageLoaders = new <URLImageLoader>[];
			//animationSets = new <AnimationSet>[];
			pieces = new <Bitmap>[];
			onLoaded = _onLoaded;
			onFailed = _onFailed;
		}
		
		public function load(sources:Array, scale:Number = 1):void {
			xmlLoaders.length = imageLoaders.length = 0;
			_textureScale = scale;
			loadStart = getTimer();
			//Logger.log("[SpriterLoader] Spriter load started...", false);
			
			var loader:URLLoader;
			for(var i:int = 0, l:int = sources.length; i < l; i++){
				//Load XML, when XML is complete, load images, when images are complete, build texture atlas, and return... 
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFailed, false, 0, true);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFailed, false, 0, true);
				loader.load(new URLRequest(sources[i]));
				
				var pathChunks:Array = sources[i].split("/");
				var fileName:String = pathChunks.pop().split(".")[0];
				
				namesByLoader[loader] = fileName;
				pathsByLoader[loader] = pathChunks.join("/");
				xmlLoaders.push(loader);
			}
		}
		
		protected function onLoadFailed(event:IOErrorEvent):void {
			if (onFailed != null) {
				onFailed(event);
				return;
			}
			var loader:URLLoader = (event.target as URLLoader);
			throw(new Error("[SpriterLoader] Unable to load SCML file for: " + namesByLoader[loader]+ "; error: "+event));
		}
		
		protected function onLoadComplete(event:Event):void {
			var loader:URLLoader = (event.target as URLLoader);
			var xml:XML = new XML(loader.data);
			spriteXml = xml;
			scmlByName[namesByLoader[loader]] = xml;
			
			var pieces:XMLList = xml..file;
			//Load each piece
			for (var i:int = 0, l:int = pieces.length(); i < l; i++) {
				//wlaMixins.LOG.apply("SpriterLoader: Loading SCML part " + (pathsByLoader[loader] + "/" + pieces[i].@name));
				var imageLoader:URLImageLoader = new URLImageLoader();
				imageLoader.addEventListener(Event.COMPLETE, onImageLoadComplete, false, 0, true);
				imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onImageLoadComplete, false, 0, true);
				imageLoader.loadImage(pathsByLoader[loader] + "/" + pieces[i].@name);
				imageLoaders.push(imageLoader);
				imageLoader.data = pieces[i].@name + "";
			}
			//Remove loader from array
			if(xmlLoaders.indexOf(loader) != -1){
				xmlLoaders.splice(xmlLoaders.indexOf(loader), 1);
			}
		}
		
		protected function onImageLoadComplete(event:Event):void {
			var loader:URLImageLoader = (event.target as URLImageLoader);
			if(loader.bmpImage && loader.bmpImage.bitmapData){
				var entityname:String = loader.data as String;
				// Removing extension
				var exntpos:int = entityname.indexOf(".");
				if (exntpos >= 0) {
					entityname = entityname.substring(0, exntpos);
				}
				loader.bmpImage.name = entityname;
				pieces.push(loader.bmpImage);
				//wlaMixins.LOG.apply("SpriterLoader: Loaded SCML part " + loader.bmpImage.name);
			}else {
				//wlaMixins.LOG.apply("SpriterLoader: NOT Loaded SCML part " + (loader.data as String));
				if (onFailed != null) {
					onFailed(event);
				}
			}
			
			//Remove loader from array
			if(imageLoaders.indexOf(loader) != -1){
				imageLoaders.splice(imageLoaders.indexOf(loader), 1);
			}
			
			//Check if complete
			if(imageLoaders.length == 0){
				buildAtlas();
			}
			
		}
		
		protected function buildAtlas():void {
			
			textureAtlas = AtlasBuilder.buildFromBitmaps(pieces, _textureScale, 2, 2048, 2048);
			atlasXml = AtlasBuilder.atlasXml;
			atlasBitmap = AtlasBuilder.atlasBitmap;
			
			//var animation:AnimationSet;
			//for(var name:String in scmlByName){
				//animation = new AnimationSet(scmlByName[name], _textureScale);
				//animation.name = name;
				//animationSets.push(animation);
			//}
		
			if(onLoaded != null){
				onLoaded(this);
				onLoaded = null;
			}
		}
		
		//public function getAnimationSet(name:String):AnimationSet {
			//for(var i:int = 0, l:int = animationSets.length; i < l; i++){
				//if(animationSets[i].name == name){
					//return animationSets[i];
				//}
			//}
			//throw(new Error("[SpriterLoader] Unable to find animation of type: '" + name + "', make sure you loaded it successfully"));
			//return null;
		//}
		//
		//
		//public function getSpriterClip(name:String):SpriterClip {
			//var animation:AnimationSet = getAnimationSet(name);
			//if(animation){
				//return new SpriterClip(animation, textureAtlas);
			//} 
			//return null;
		//}
		
		public function disposeTextures():void {
			if(!textureAtlas){ return; }
			textureAtlas.dispose();
			textureAtlas = null;
		}
		
		public function restoreTextures():void {
			textureAtlas = new TextureAtlas(Texture.fromBitmapData(atlasBitmap), atlasXml);
		}
		
	}
}