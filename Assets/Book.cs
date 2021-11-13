using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;

public class Book : MonoBehaviour
{
    [SerializeField]  UnityEvent OnSelected;

    private bool onPlace ;
    private bool grabed;
    BookPlace bookPlace;
    [SerializeField] private GameObject otherBook;


    private void Start()
    {
        bookPlace = FindObjectOfType<BookPlace>();
    }

    private void Update()
    {
        if (onPlace) { OnSelected.Invoke();  }
    }
    public void OnTable()
    {
        gameObject.GetComponent<XRGrabInteractable>().enabled = false;
        TweenBook();
        
        gameObject.GetComponent<Collider>().enabled = false;
        
    }

    IEnumerator hightLite()
    {
        this.gameObject.GetComponent<Outline>().enabled=true ; 
        yield return new WaitForSeconds(0.8f);
        this.gameObject.GetComponent<Outline>().enabled = false;
        yield return new WaitForSeconds(0.8f);
        if(!grabed && bookPlace.Near() && !onPlace) StartCoroutine(hightLite());
    }

    public void OnGrabed(){  grabed = true; }

    public void ExitGrab() { grabed = false; StartCoroutine(hightLite()); }

    public void HightLiteBook()
    {
        StartCoroutine(hightLite());
    }

    public void TweenBook()
    {

        LeanTween.move(this.gameObject, otherBook.transform.position, 1f);
        LeanTween.rotate(this.gameObject, otherBook.transform.eulerAngles, 1);
        StartCoroutine(SetHandel());
        
    }

    IEnumerator SetHandel()
    {
        yield return new WaitForSeconds(1.1f);
        this.gameObject.SetActive(false);
        otherBook.SetActive(true);
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Book")
        {
            onPlace = true;

        }
    }
}
