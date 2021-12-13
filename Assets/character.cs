using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class character : MonoBehaviour
{
    public Camera camere;
    bool walk;
    bool wave;
    bool clam;
    bool lookAt;

    public GameObject teleport;
    Animator animator;
    public GameObject otherCharacter;

    public bool GoHead;

    private void Awake()
    {
        animator = this.GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Vector3.Distance(this.transform.position, camere.transform.position) < 3 && !walk)
        {
            Go();
        }
        else if(!walk)
        {
            Vector3 target = new Vector3(camere.transform.position.x, transform.position.y, camere.transform.position.z);
            this.transform.parent.gameObject.transform.LookAt(target);
            Wave();
        }

        if(lookAt)
        {
            Vector3 target = new Vector3(camere.transform.position.x, transform.position.y, camere.transform.position.z);
            this.transform.LookAt(target);
        }

        if (GoHead)
        {

        }
    }


    public void Wave()
    {
        animator.SetBool("Wave", true);
    }

    

    public void Go()
    {
        walk = true;
        animator.SetTrigger("Go");
        StartCoroutine(Run());
       
        
    }

    IEnumerator Run()
    {
        yield return new WaitForSeconds(1f);
        LeanTween.rotateY(this.gameObject.transform.parent.gameObject, 170, 1f);
        teleport.SetActive(true);
        yield return new WaitForSeconds(1f);
        animator.SetTrigger("Walk");
        LeanTween.move(this.gameObject.transform.parent.gameObject, otherCharacter.transform.position,4f);
        yield return new WaitForSeconds(4f);
        animator.SetBool("Wave", false);
        animator.SetTrigger("Idel");
        LeanTween.rotate(this.gameObject.transform.parent.gameObject, otherCharacter.transform.localEulerAngles, 1f);
        yield return new WaitForSeconds(1f);
        otherCharacter.SetActive(true);
        this.gameObject.SetActive(false);
    }

    public void Clam()
    {
        animator.SetTrigger("Clam");
    }
}
