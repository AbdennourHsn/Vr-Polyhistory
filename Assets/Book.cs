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
    [SerializeField] private GameObject canvase , handel , join;


    private void Start()
    {
        bookPlace = FindObjectOfType<BookPlace>();
    }

    private void Update()
    {
        if (onPlace) OnSelected.Invoke();
    }
    public void OnTable(Transform target)
    {
        gameObject.GetComponent<XRGrabInteractable>().enabled = false;
        TweenBook(target);
        
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

    public void TweenBook(Transform Target )
    {
        LeanTween.move(this.gameObject, Target.position, 1f);
        LeanTween.rotate(this.gameObject, Target.eulerAngles, 1);
        StartCoroutine(SetHandel());
        
    }

    IEnumerator SetHandel()
    {
        yield return new WaitForSeconds(1.2f);
        
        handel.SetActive(true);
       
        join.SetActive(true);
        if (canvase != null)
        {
            Vector3 canvasScal = canvase.gameObject.transform.localScale;
            canvase.gameObject.transform.localScale = Vector3.zero;
            canvase.SetActive(true);
            LeanTween.scale(canvase, canvasScal, 1);
        }

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Book")
        {
            onPlace = true;
        }
    }
}
