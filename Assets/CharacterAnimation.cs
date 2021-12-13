using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimation : MonoBehaviour
{
    private Animator animator;

    Vector3 PosIni;
    // Start is called before the first frame update
    void Start()
    {
        PosIni = gameObject.transform.position;
        animator = this.GetComponent<Animator>();
        StartCoroutine(walk());
    }

    IEnumerator walk()
    {
        
        animator.SetTrigger("Walk");
        LeanTween.moveLocalX(this.gameObject, PosIni.x + 8,5f);
        yield return new WaitForSeconds(5);
        animator.SetTrigger("turn");
        LeanTween.rotateAround(gameObject,Vector3.up ,180, 0.8f);
        yield return new WaitForSeconds(0.9f);
        animator.SetTrigger("Walk"); 
        LeanTween.moveLocalX(this.gameObject, PosIni.x , 5f);
        yield return new WaitForSeconds(5);
        animator.SetTrigger("turn");
        LeanTween.rotateAround(gameObject, Vector3.up, 180, 0.8f);
        yield return new WaitForSeconds(0.9f);
        StartCoroutine(walk());

    }
}
