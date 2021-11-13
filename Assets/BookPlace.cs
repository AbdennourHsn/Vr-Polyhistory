using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BookPlace : MonoBehaviour
{
    public Camera cameraPlayer;
    public float distance=5;
    public GameObject canvas;
    bool near;
    bool bookOnTable;
    public Book book;

    private void Start()
    {
        book=FindObjectOfType<Book>();
    }

    private void Update()
    {
        if (Vector3.Distance(cameraPlayer.transform.position, this.transform.position) < distance && !bookOnTable)
        {
            if (!near)
            {
                StartCoroutine(hightLight());
                book.HightLiteBook();
            }
            near = true;
            canvas.gameObject.SetActive(true);
           
        }
        else { near = false; canvas.gameObject.SetActive(false); }
        
    }
    

    IEnumerator hightLight()
    {
        this.gameObject.GetComponent<MeshRenderer>().enabled = true;
        yield return new WaitForSeconds(1.2f);
        this.gameObject.GetComponent<MeshRenderer>().enabled = false;
        yield return new WaitForSeconds(1.2f);
        if(near && !bookOnTable) StartCoroutine(hightLight());
        

    }
    public bool Near() { return near; }
    public void SetbookOn(bool bookOnTable)
    {
        this.bookOnTable = bookOnTable;
        
    }
}
