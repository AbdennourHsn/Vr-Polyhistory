using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ImgController : MonoBehaviour
{
    public RawImage[] rawImages;
    int currImg;
    [SerializeField] Button next , prev;

    private void Start()
    {
        rawImages[0].gameObject.SetActive(true);
        for (int i = 1; i < rawImages.Length; i++) rawImages[i].gameObject.SetActive(false);
        currImg = 0;
        transform.localScale = new Vector3(0, 0, 0);
    }
    private void Update()
    {
        if (currImg == 0) prev.gameObject.SetActive(false);
        if (currImg == (rawImages.Length - 1)) next.gameObject.SetActive(false);
        else
        {
            next.gameObject.SetActive(true);
            prev.gameObject.SetActive(true);
        }
    }
    public void NextImg()
    {
        rawImages[currImg].gameObject.SetActive(false);
        currImg++;
        rawImages[currImg].gameObject.SetActive(true);
    }
    public void PrevImg()
    {
        rawImages[currImg].gameObject.SetActive(false);
        currImg--;
        rawImages[currImg].gameObject.SetActive(true);
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

}
