using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ImgController : MonoBehaviour
{
    public RawImage[] rawImages;
    int currImg;
    [SerializeField] Button next , prev , LoadNextScean;


    private void Start()
    {
        LoadNextScean.gameObject.SetActive(false);
        rawImages[0].gameObject.SetActive(true);
        for (int i = 1; i < rawImages.Length; i++) rawImages[i].gameObject.SetActive(false);
        currImg = 0;
       
    }
    private void OnEnable()
    {
        transform.localScale = new Vector3(0, 0, 0);
        StartCoroutine(ShowButton());
    }

    public void NextImg()
    {
        
        rawImages[currImg].gameObject.SetActive(false);
        currImg++;
        rawImages[currImg].gameObject.SetActive(true);
        check();
    }
    public void PrevImg()
    {
        rawImages[currImg].gameObject.SetActive(false);
        currImg--;
        rawImages[currImg].gameObject.SetActive(true);
        check();
    }
    private void check()
    {
        if (currImg == 0) prev.gameObject.SetActive(false);
        else prev.gameObject.SetActive(true);
        if (currImg == rawImages.Length - 1) next.gameObject.SetActive(false);
        else next.gameObject.SetActive(true);
    }
    public void AnimateCanv()
    {
        StartCoroutine(Scale());
    }

    IEnumerator Scale()
    {
        yield return new WaitForSeconds(1);
        LeanTween.scale(this.gameObject, new Vector3(1, 1, 1), 2f);
    }

    IEnumerator ShowButton()
    {
        yield return new WaitForSeconds(3f);
        LoadNextScean.gameObject.SetActive(true);
    }

}
