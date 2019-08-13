using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Assets.Scripts.BrowseElementsWindow
{
    [RequireComponent( typeof( UIElement ) )]
    public class ElementView : MonoBehaviour
    {
        public UIElement ui;
        public KeyValuePair<int, int> element;

        void Awake ()
        {
            ui = GetComponent<UIElement>();
        }

        public void SetElement ( KeyValuePair<int, int> _element )
        {
            element = _element;
            SetText( _element.Value );
        }

        public void SetText ( int _number )
        {
            ui.mainText.text = _number.ToString();
        }

        public void SetSelected ( bool _value )
        {
            ui.selected.SetActive( _value );
        }

        public void SetButtonAction ( UnityAction<ElementView> _action )
        {
            ui.button.onClick.RemoveAllListeners();
            ui.button.onClick.AddListener( () => _action( this ) );
        }
    }
}
