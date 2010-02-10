package net.tw.webapis.fotolia {
	import net.tw.webapis.fotolia.abstract.FotoliaServiceRequester;
	import org.osflash.signals.Signal;
	import net.tw.webapis.fotolia.util.DataParser;
	/**
	 * Represents a Fotolia category.
	 */
	public class FotoliaCategory extends FotoliaServiceRequester {
		public static const TYPE_REPRESENTATIVE:uint=1;
		public static const TYPE_CONCEPTUAL:uint=2;
		//
		public static const METHOD_GET_CATEGORIES_REPRESENTATIVE:String='xmlrpc.getCategories1';
		public static const METHOD_GET_CATEGORIES_CONCEPTUAL:String='xmlrpc.getCategories2';
		//
		protected var _type:uint;
		protected var _langID:uint;
		protected var _parent:FotoliaCategory;
		//
		protected var _gotCategories:Signal=new Signal(Array);
		/**
		 * @param	pService	Used for its API key and fault handler
		 * @param	pProps		Random properties to be passed-in
		 * @param	pType		Can be either 1 (Representative) or 2 (Conceptual)
		 * @param	pLangID
		 * @param	pParent		The parent FotoliaCategory
		 */
		public function FotoliaCategory(pService:FotoliaService, pProps:Object, pType:uint, pLangID:uint=0, pParent:FotoliaCategory=null) {
			super(pService);
			_props=pProps;
			_type=pType;
			_langID=_service.defLang(pLangID);
			_parent=pParent;
		}
		/**
		 * Parent category
		 */
		public function get parent():FotoliaCategory {
			return _parent;
		}
		/**
		 * Boolean indicating if this category is a root one.
		 */
		public function isAtRoot():Boolean {
			return !_parent;
		}
		/**
		 * Boolean indicating if this category is a leaf one (so cannot have any sub-categories).
		 */
		public function isLeaf():Boolean {
			return props.nb_sub_categories==0;
		}
		/**
		 * Category type. Can be either 1 (Representative) or 2 (Conceptual).
		 */
		public function get type():uint {
			return _type;
		}
		/**
		 * Boolean indicating if this category is a representative one.
		 */
		public function isRepresentative():Boolean {
			return type==1;
		}
		/**
		 * Boolean indicating if this category is a conceptual one.
		 */
		public function isConceptual():Boolean {
			return type==2;
		}
		/**
		 * Category's language ID.
		 * @see FotoliaService
		 */
		public function get langID():uint {
			return _langID;
		}
		/**
		 * Category's name.
		 */
		public function get name():String {
			return props.name;
		}
		public function get cleanName():String {
			return name.replace('&amp;', '&');
		}
		/**
		 * Category's ID
		 */
		public function get id():uint {
			return props.id;
		}
		/**
		 * Utility method to get a category method's name from a category type ID
		 * @param	type
		 * @return	The method name to use for the given type
		 */
		public static function getCategoryMethod(type:uint):String {
			return type==FotoliaCategory.TYPE_REPRESENTATIVE ? METHOD_GET_CATEGORIES_REPRESENTATIVE : METHOD_GET_CATEGORIES_CONCEPTUAL;
		}
		/**
		 * Signal dispatched after a getCategories call
		 * Listeners will receive 1 argument: an Array of FotoliaCatory objects
		 * @see #getCategories
		 */
		public function get gotCategories():Signal {
			return _gotCategories;
		}
		/**
		 * Remote getCategories call
		 * @param	pLangID
		 * @see #gotCategories
		 * @see http://us.fotolia.com/Services/API/Method/getCategories1
		 * @see http://us.fotolia.com/Services/API/Method/getCategories2
		 */
		public function getCategories(pLangID:uint=0):void {
			var lid:uint=pLangID>0 ? pLangID : langID;
			loadRequest(
				getCategoryMethod(type),
				[key, lid, id],
				gotCategories,
				DataParser.objectToCategories,
				[_service, type, lid, this]
			);
		}
	}
}