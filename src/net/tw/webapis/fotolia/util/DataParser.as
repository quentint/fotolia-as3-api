package net.tw.webapis.fotolia.util {
	import mx.utils.ObjectUtil;
	
	import net.tw.webapis.fotolia.*;
	/**
	 * Utility class to convert Objects to Fotolia specific types.
	 */
	public class DataParser {
		public static function objectToArray(o:Object):Array {
			var a:Array=[];
			for each(var item:* in o) a.push(item);
			return a;
		}
		public static function firstObjectItemToArray(o:Object):Array {
			for each(var item:* in o) return objectToArray(item);
			return [];
		}
		public static function firstObjectItemToBoolean(o:Object):Boolean {
			for each(var item:* in o) return item;
			return false;
		}
		public static function firstObjectItemToObject(o:Object):* {
			for each(var item:* in o) return item;
			return null;
		}
		public static function objectArrayToFirstObjectItemArray(a:Array):Array {
			var ar:Array=[];
			for each (var item:Object in a) ar.push(firstObjectItemToObject(item));
			return ar;
		}
		
		public static function traceObject(...args:Array):Array {
			trace('traceObject--');
			trace(ObjectUtil.toString(args));
			return args;
		}
		
		public static function getDataHandler(o:Object):Object {
			o.languages=objectToArray(o.languages);
			return o;
		}
		public static function userHandler(o:Object, params:Array):FotoliaUser {
			return new FotoliaUser(params[0], o.session_id, params[1], params[2]);
		}
		public static function arrayToGalleries(a:Array, params:Array):* {
			var gs:Array=[];
			for each (var item:Object in a) {
				gs.push(new FotoliaGallery(params[0], item));
			}
			return params.length==2 ? {res:gs, target:params[1]} : gs;
		}
		public static function arrayToUserGalleries(a:Array, params:Array):Object {
			var gs:Array=[];
			for each (var item:Object in a) {
				gs.push(new FotoliaUserGallery(params[0], item, params[1]));
			}
			return {res:gs, target:params[1]};
		}
		public static function createdGalleryToUserGallery(o:Object, params:Array):Object {
			o.name=params[2];
			return {res:new FotoliaUserGallery(params[0], o, params[1]), target:params[1]};
		}
		public static function successStringObjectToBoolean(o:Object):Boolean {
			for each(var item:* in o) return item=='SUCCESS';
			return false;
		}
		public static function objectToCategories(o:Object, params:Array):* {
			var cs:Array=[];
			var cat:FotoliaCategory;
			for each(var item:Object in o) {
				//cat=new FotoliaCategory(params[0], item, params[1]/*, params[2], params[3]*/);
				cat=FotoliaCategory.getFromProps(params[0], item, params[1]/*, params[2], params[3]*/);
				cat.parent=params[3];
				cs.push(cat);
			}
			return params.length==4 ? {res:cs, target:params[3]} : cs;
		}
		public static function objectToSearchResults(o:Object, params:Object):FotoliaSearchResults {
			var medias:Array=[];
			for (var p:String in o) {
				if (!/^[0-9]*$/.test(p)) continue;
				//medias.push(new FotoliaMedia(params[0], o[p]));
				medias.push(FotoliaMedia.getFromProps(params[0], o[p]));
			}
			return new FotoliaSearchResults(o.nb_results, medias);
		}
		public static function rawObjectTargetHandler(o:Object, params:Array):Object {
			return {res:o, target:params[0]};
		}
		public static function targetHandler(o:Object, params:Array):Object {
			return {target:params[0]};
		}
		public static function purchaseHandler(o:Object, params:Array):Object {
			return {res:o, target:params[0]};
		}
		/*public static function targetSuccessStringObjectToBoolean(o:Object, params:Array):Object {
			return {res:successStringObjectToBoolean(o), target:params[0]};
		}*/
	}
}