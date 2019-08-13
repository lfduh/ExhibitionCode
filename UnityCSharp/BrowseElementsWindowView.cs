using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Assets.Scripts.BrowseElementsWindow
{
    [RequireComponent( typeof( UIBrowseElementsWindow ) )]
    public class BrowseElementsWindowView : MonoBehaviour
    {
        public UIBrowseElementsWindow ui;
        public ElementView currentSelectElement;

        void Awake ()
        {
            ui = GetComponent<UIBrowseElementsWindow>();
        }

        public void SetElements ( Dictionary<int, int> _elements )
        {
            foreach( Transform _child in ui.elementsGrid.transform )
            {
                Destroy( _child.gameObject );
            }

            foreach( var _kvp in _elements )
            {
                var newCardUI = Instantiate( ui.elementsPrefab, ui.elementsGrid.transform );
                var newCard = newCardUI.gameObject.AddComponent<ElementView>();
                newCard.SetElement( _kvp );
                newCard.SetButtonAction( SelectElement );
            }
        }

        void SelectElement ( ElementView _element )
        {
            if( currentSelectElement != null ) currentSelectElement.SetSelected( false );
            currentSelectElement = _element;
            _element.SetSelected( true );
        }

        public void SetConfirmButtonAction ( UnityAction<KeyValuePair<int, int>> _action )
        {
            ui.confirmButton.onClick.RemoveAllListeners();
            ui.confirmButton.onClick.AddListener( () => _action( currentSelectElement.element ) );
        }

        public void SetCancelButtonAction ( UnityAction _action )
        {
            ui.cancelButton.onClick.RemoveAllListeners();
            ui.cancelButton.onClick.AddListener( _action );
        }

        public void SetTitle ( string _title )
        {
            ui.titleText.text = _title;
        }
    }
}
