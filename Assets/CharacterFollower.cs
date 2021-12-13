using System.Collections;
using System.Collections.Generic;
using Dreamteck.Splines;
using UnityEngine;

public class CharacterFollower : MonoBehaviour
{
    Animator animator;
    // Start is called before the first frame update
    void Start()
    {
        animator = this.GetComponent<Animator>();
    }

    public void Clam()
    {
        animator.SetTrigger("Clam");
        StartCoroutine(run());
    }

    IEnumerator run()
    {
        yield return new WaitForSeconds(1.5f);
        gameObject.transform.parent.gameObject.GetComponent<SplineFollower>().enabled = true;
        animator.SetTrigger("Run");
    }
}
