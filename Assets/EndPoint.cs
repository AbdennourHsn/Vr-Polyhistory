using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndPoint : MonoBehaviour
{
    Vector3 ScaleIni;
    bool animate;
    private void Start()
    {
        animate = true;
        ScaleIni = this.gameObject.transform.localScale;
        StartCoroutine(AnimScale());
    }

    public void AnimatePoint()
    {
        
    }

    IEnumerator AnimScale()
    {
        LeanTween.scale(this.gameObject, new Vector3(ScaleIni.x / 2, ScaleIni.y / 2, ScaleIni.z / 2), 0.5f);
        yield return new WaitForSeconds(0.5f);
        LeanTween.scale(this.gameObject, new Vector3(ScaleIni.x, ScaleIni.y, ScaleIni.z), 0.5f);
        yield return new WaitForSeconds(0.5f);
        StartCoroutine(AnimScale());
    }
}
